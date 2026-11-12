module Briefly
  # Bridges Article and Story: rules cut the pile, the LLM assigns sections,
  # the picks become story skeletons in the briefing.
  class Selector
    def self.call(briefing, articles: Article.since(24.hours.ago), assign: nil)
      return [] if briefing.stories.exists?

      candidates = Candidates.call(articles)
      picks = assign ? Assign.call(candidates, assign:) : Assign.fallback(candidates)
      by_id = candidates.index_by(&:id)

      picks.filter_map do |pick|
        article = by_id[pick[:article_id]]
        next unless article

        briefing.stories.create!(
          section: pick[:section],
          title: article.title,
          source_name: article.source.name,
          url: article.url,
          # Feed summaries can be empty; the writer (step 3) replaces this anyway.
          summary: article.summary.presence || article.title,
          published_at: article.published_at,
          stretch: pick[:stretch],
          article:
        )
      end
    end
  end
end
