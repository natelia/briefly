module Briefly
  # Selection bridges the raw pile (Article) and the reader's world (Story):
  # rules cut the pile to ~30 candidates, the LLM assigns sections, and the
  # picks become story skeletons inside the given briefing. The writer
  # (step 3) later fills the summaries these skeletons carry.
  class Selector
    # briefing: the Briefing to fill (today's, usually)
    # articles: the pile to select from — pass a scoped relation or an array
    # assign:   the LLM callable; nil means rules-only selection
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
          # Feed summaries can be empty; the title stands in until the
          # writer (step 3) replaces it.
          summary: article.summary.presence || article.title,
          published_at: article.published_at,
          stretch: pick[:stretch],
          article:
        )
      end
    end
  end
end
