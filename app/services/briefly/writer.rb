module Briefly
  # Step 3 of the pipeline: the LLM rewrites the skeleton summaries in the
  # briefing's voice. One call per briefing. A failed or invalid answer
  # keeps the placeholder summaries — the briefing always exists.
  class Writer
    SUMMARY_LIMIT = 200
    DIGEST_LIMIT = 2000
    FEED_CONTEXT = 2000

    def self.call(briefing, complete: ->(prompt) { Llm::Client.complete(prompt) })
      stories = briefing.stories.order(:id).to_a
      return 0 if stories.empty?

      updates = parse(complete.call(prompt(stories)), stories)
      updates.each { |story, fields| story.update!(**fields) }
      updates.size
    rescue StandardError => e
      Rails.logger.warn("[briefly] writer: #{e.class} #{e.message}")
      0
    end

    def self.prompt(stories)
      <<~PROMPT
        You write the summaries of a daily tech briefing for a software developer.
        Voice rules:
        - Active voice, short sentences (max 20 words), name the actor.
        - One word, one meaning. Keep technical terms, expand an acronym once.
        - No hedging (perhaps, arguably), no marketing tone, no alarm.

        Sections:
        - must_know: neutral, factual, present tense.
        - for_you: same rules, a notch warmer, written for this one reader.
        - one_new_thing: same rules, one genuinely new idea.

        Two texts per story, both in the briefing's voice:
        - summary: the card teaser. One sentence, max 20 words, makes the
          reader want to open the card. No spoilers of detail.
        - digest: the card's own page. 2-3 short paragraphs (max 60 words
          each) that retell the article in more detail: what it is, how it
          works, what follows. Only facts present in the input.

        A stretch story is outside the reader's field. Start its summary with
        "A stretch pick:" and also give why_it_matters: one sentence that
        connects the story to this reader's world.

        Input: stories as JSON. The feed_summary is raw feed text, sometimes
        HTML, sometimes empty. Use it. If it is empty, write from the
        title and the source alone.

        Answer with strict JSON, nothing else. One object per input story:
        [{"id": 1, "summary": "...", "digest": "para1\n\npara2\n\npara3"}]
        why_it_matters only for stretch stories. Separate digest paragraphs
        with a blank line. Summaries and digests in English.

        Stories:
        #{JSON.pretty_generate(payload(stories))}
      PROMPT
    end

    def self.payload(stories)
      stories.map do |story|
        { id: story.id, section: story.section, stretch: story.stretch,
          title: story.title, source: story.source_name,
          feed_summary: clean(story.summary) }
      end
    end

    # Untrusted answer -> { story => { summary:, digest:, why_it_matters?: } }.
    # Unknown ids, empty or oversized texts, bad JSON: skipped.
    def self.parse(raw, stories)
      list = JSON.parse(raw.to_s)
      return {} unless list.is_a?(Array)

      by_id = stories.index_by(&:id)
      list.filter_map do |entry|
        next unless entry.is_a?(Hash)

        story = by_id[entry["id"]]
        summary = entry["summary"].to_s.strip
        next unless story && summary.present? && summary.length <= SUMMARY_LIMIT

        fields = { summary: }
        digest = entry["digest"].to_s.strip
        fields[:digest] = digest if digest.present? && digest.length <= DIGEST_LIMIT
        why = entry["why_it_matters"].to_s.strip
        fields[:why_it_matters] = why if why.present?
        [ story, fields ]
      end.to_h
    rescue JSON::ParserError
      {}
    end

    def self.clean(text)
      text.to_s.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
           .truncate(FEED_CONTEXT, omission: "…")
    end
  end
end
