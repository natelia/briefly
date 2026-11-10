require "test_helper"

class Briefly::Selector::CandidatesTest < ActiveSupport::TestCase
  test "orders newest first and respects the limit" do
    source = create(:source)
    oldest = create(:article, source:, title: "Oldest", published_at: 3.days.ago)
    newest = create(:article, source:, title: "Newest", published_at: 10.minutes.ago)
    create(:article, source:, title: "Middle", published_at: 2.hours.ago)

    result = Briefly::Selector::Candidates.call(Article.all, limit: 2)

    assert_equal 2, result.size
    assert_equal newest, result.first
    assert_not_includes result, oldest
  end

  test "caps how many candidates one source can contribute" do
    loud = create(:source, name: "Loud feed")
    quiet = create(:source, name: "Quiet feed")
    create_list(:article, 10, source: loud, published_at: 1.hour.ago)
    create(:article, source: quiet, title: "From the quiet feed", published_at: 2.hours.ago)

    result = Briefly::Selector::Candidates.call(Article.all, per_source_cap: 3)

    assert_equal 3, result.count { _1.source == loud }
    assert_equal 1, result.count { _1.source == quiet }
  end

  test "drops articles without a published_at instead of crashing" do
    source = create(:source)
    dated = create(:article, source:, published_at: 1.hour.ago)
    create(:article, source:, published_at: nil)

    assert_equal [ dated ], Briefly::Selector::Candidates.call(Article.all)
  end

  test "dedupes republished titles, keeping the newest copy" do
    source = create(:source)
    create(:article, source:, title: "Postgres 18 ships!", published_at: 5.hours.ago)
    newest_copy = create(:article, source:, title: "postgres 18 ships", published_at: 30.minutes.ago)

    result = Briefly::Selector::Candidates.call(Article.all)

    assert_equal 1, result.size
    assert_equal newest_copy, result.first
  end
end
