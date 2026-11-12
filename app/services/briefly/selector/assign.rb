module Briefly
  class Selector
    # Asks the LLM to pick 7 stories and assign sections.
    # A broken answer falls back to `fallback`.
    class Assign
      SLOTS = { "must_know" => 3, "for_you" => 3, "one_new_thing" => 1 }.freeze

      def self.call(candidates, assign:)
        payload = candidates.map do |article|
          {
            id: article.id,
            title: article.title,
            summary: article.summary,
            source: article.source.name
          }
        end

        answer = parse(assign.call(payload))
        if answer && valid?(answer, candidates)
          picks_from(answer)
        else
          fallback(candidates)
        end
      end

      # The pick without any model: newest candidates in fixed section order.
      def self.fallback(candidates)
        sections = []
        SLOTS.each do |section, count|
          count.times { sections << section }
        end

        picks = []
        sections.each_with_index do |section, index|
          article = candidates[index]
          if article
            picks << { article_id: article.id, section: section, stretch: false }
          end
        end

        stretch = picks.reverse.find { |pick| pick[:section] == "for_you" }
        stretch[:stretch] = true if stretch
        picks
      end

      def self.parse(raw)
        JSON.parse(raw.to_s)
      rescue JSON::ParserError
        nil
      end

      def self.valid?(answer, candidates)
        known_ids = candidates.map(&:id)

        SLOTS.each do |section, count|
          list = answer[section]
          return false unless list.is_a?(Array)
          return false unless list.size == count
        end

        all_ids = SLOTS.keys.flat_map { |section| answer[section] }
        return false unless all_ids.uniq.size == all_ids.size
        return false unless all_ids.all? { |id| known_ids.include?(id) }

        answer["stretch"].is_a?(Integer) && answer["for_you"].include?(answer["stretch"])
      end

      def self.picks_from(answer)
        picks = []
        SLOTS.each_key do |section|
          answer[section].each do |id|
            picks << { article_id: id, section: section, stretch: false }
          end
        end

        picks.each do |pick|
          if pick[:section] == "for_you" && pick[:article_id] == answer["stretch"]
            pick[:stretch] = true
          end
        end

        picks
      end
    end
  end
end
