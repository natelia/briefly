module Briefly
  class Selector
    # Stage 1 — deterministic rules. No LLM, no network: the same pile of
    # articles always produces the same candidates. The LLM (stage 2) never
    # sees the raw pile — rules cut it first, so the model gets a list small
    # enough to judge well and cheap to send.
    class Candidates
      LIMIT = 30
      PER_SOURCE_CAP = 8

      # Returns candidate articles, newest first: per-source cap, then
      # title dedup, then the limit.
      def self.call(articles, limit: LIMIT, per_source_cap: PER_SOURCE_CAP)
        newest_first = articles
                         .select(&:published_at)
                         .sort_by { |article| -article.published_at.to_i }

        cap_per_source(newest_first, per_source_cap)
          .then { |capped| dedupe_titles(capped) }
          .first(limit)
      end

      # One loud source (Hacker News) must not flood the candidate list.
      # Hash.new(0) counts from zero: the first article of a source counts
      # 1, the ninth no longer passes an 8-cap.
      def self.cap_per_source(articles, cap)
        per_source = Hash.new(0)
        # Parentheses matter: += binds last, so without them Ruby would
        # assign the comparison result instead of counting.
        articles.select { (per_source[_1.source_id] += 1) <= cap }
      end

      # Feeds republish the same story under slightly different titles.
      # We compare normalized titles and keep the first one seen — the list
      # is newest first, so the newest copy survives.
      def self.dedupe_titles(articles)
        seen = {}
        articles.filter_map do |article|
          key = normalize(article.title)
          next if seen[key]

          seen[key] = true
          article
        end
      end

      # Downcase, strip punctuation, squeeze spaces: "Postgres 18 ships!"
      # and "postgres 18 ships" become the same key.
      def self.normalize(title)
        title.to_s.downcase.gsub(/[^a-z0-9]+/, " ").strip
      end
    end
  end
end
