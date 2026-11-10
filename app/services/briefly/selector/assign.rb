module Briefly
  class Selector
    # Stage 2 — the LLM assigns sections to the candidates. The model's
    # answer is untrusted input: every id and count is validated, and
    # anything wrong falls back to a deterministic pick. A briefing must
    # exist even on the model's worst day.
    #
    # The contract the model must answer with (JSON):
    #   { "must_know":     [id, id, id],
    #     "for_you":       [id, id, id],
    #     "one_new_thing": [id],
    #     "stretch":       id }        # one of the for_you ids
    class Assign
      SLOTS = { "must_know" => 3, "for_you" => 3, "one_new_thing" => 1 }.freeze

      # assign: a callable that receives the candidate payload (array of
      # hashes) and returns the model's answer as a JSON string. Injected,
      # never hardcoded — tests pass a lambda, the real client arrives in
      # step 3 (same convention as Briefly::Feed's fetch lambda).
      def self.call(candidates, assign:)
        payload = candidates.map do |article|
          { id: article.id, title: article.title, summary: article.summary,
            source: article.source.name }
        end

        answer = parse(assign.call(payload))
        return fallback(candidates) unless answer && valid?(answer, candidates)

        picks_from(answer)
      end

      # The deterministic pick, used when no assign callable is given or the
      # model's answer fails validation: newest first — 3 must_know, 3
      # for_you (the last one stretches), 1 one_new_thing.
      def self.fallback(candidates)
        slots = SLOTS.flat_map { |section, count| [ section ] * count }
        picks = candidates.first(slots.size).zip(slots).filter_map do |article, section|
          { article_id: article.id, section:, stretch: false } if article
        end
        stretch_pick = picks.reverse.find { _1[:section] == "for_you" }
        stretch_pick[:stretch] = true if stretch_pick
        picks
      end

      # -- answer handling -------------------------------------------------

      def self.parse(raw)
        JSON.parse(raw.to_s)
      rescue JSON::ParserError
        nil
      end

      def self.valid?(answer, candidates)
        known = candidates.map(&:id)
        ids = []

        SLOTS.each do |section, count|
          list = answer[section]
          return false unless list.is_a?(Array) && list.size == count

          ids.concat(list)
        end

        ids.uniq.size == ids.size && ids.all? { known.include?(_1) } &&
          answer["stretch"].is_a?(Integer) && answer["for_you"].include?(answer["stretch"])
      end

      def self.picks_from(answer)
        picks = SLOTS.flat_map do |section, _count|
          answer[section].map { { article_id: _1, section:, stretch: false } }
        end
        picks.find { _1[:section] == "for_you" && _1[:article_id] == answer["stretch"] }[:stretch] = true
        picks
      end
    end
  end
end
