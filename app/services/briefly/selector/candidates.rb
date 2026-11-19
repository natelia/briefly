module Briefly
  class Selector
    # Stage 1 — deterministic rules: the same articles always give the same candidates.
    class Candidates
      LIMIT = 30
      PER_SOURCE_CAP = 8
      MIN_SUMMARY = 80

      def self.call(articles, limit: LIMIT, per_source_cap: PER_SOURCE_CAP)
        newest_first = articles
                         .select(&:published_at)
                         .sort_by { |article| -article.published_at.to_i }
                         .then { |dated| with_substance(dated) }

        cap_per_source(newest_first, per_source_cap)
          .then { |capped| dedupe_titles(capped) }
          .first(limit)
      end

      # An article whose summary is only markup or a bare link has nothing
      # for the selector or the writer to work with — drop it before ranking.
      def self.with_substance(articles)
        articles.select do |article|
          article.summary.to_s.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip.length >= MIN_SUMMARY
        end
      end

      def self.cap_per_source(articles, cap)
        per_source = Hash.new(0)
        articles.select { |article| (per_source[article.source_id] += 1) <= cap }
      end

      def self.dedupe_titles(articles)
        seen = {}
        articles.filter_map do |article|
          key = normalize(article.title)
          next if seen[key]

          seen[key] = true
          article
        end
      end

      def self.normalize(title)
        title.to_s.downcase.gsub(/[^a-z0-9]+/, " ").strip
      end
    end
  end
end
