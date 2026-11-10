require "test_helper"

class Briefly::SelectorTest < ActiveSupport::TestCase
  def pile(count, source: nil)
    source ||= create(:source)
    create_list(:article, count, source:, published_at: 1.hour.ago)
  end

  def valid_answer_for(articles)
    ids = Briefly::Selector::Candidates.call(articles).map(&:id)
    JSON.generate({ must_know: ids[0, 3], for_you: ids[3, 3],
                    one_new_thing: [ ids[6] ], stretch: ids[4] })
  end

  test "fills an empty briefing with seven story skeletons" do
    briefing = create(:briefing)
    articles = pile(9)

    stories = Briefly::Selector.call(briefing, articles:)

    assert_equal 7, stories.size
    assert_equal 3, briefing.stories.must_know.count
    assert_equal 3, briefing.stories.for_you.count
    assert_equal 1, briefing.stories.one_new_thing.count
    assert_equal 1, briefing.stories.where(stretch: true).count
    stories.each do |story|
      assert story.article, "every skeleton links back to its article"
      assert_equal story.article.source.name, story.source_name
      assert_equal story.article.url, story.url
    end
  end

  test "uses the model answer when it passes validation" do
    briefing = create(:briefing)
    articles = pile(7)
    answer = valid_answer_for(articles)
    asked = []
    assign = ->(payload) { asked << payload; answer }

    Briefly::Selector.call(briefing, articles:, assign:)

    assert_equal 7, asked[0].size, "the model sees exactly the candidates"
    assert asked[0].all? { _1.keys == %i[id title summary source] }
  end

  test "falls back to rules-only selection when the model answers garbage" do
    briefing = create(:briefing)
    articles = pile(7)

    stories = Briefly::Selector.call(briefing, articles:, assign: ->(_p) { "no json here" })

    assert_equal 7, stories.size
    assert_equal 3, briefing.stories.must_know.count
  end

  test "rules-only selection when no assign callable is given" do
    briefing = create(:briefing)
    articles = pile(7)

    stories = Briefly::Selector.call(briefing, articles:)

    assert_equal 7, stories.size
  end

  test "never double-fills a briefing that already has stories" do
    briefing = create(:briefing)
    create(:story, briefing:)
    pile(7)

    assert_equal [ ], Briefly::Selector.call(briefing, articles: Article.all)
    assert_equal 1, briefing.stories.count
  end
end
