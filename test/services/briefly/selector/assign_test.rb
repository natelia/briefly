require "test_helper"

class Briefly::Selector::AssignTest < ActiveSupport::TestCase
  def candidates(count)
    source = create(:source)
    create_list(:article, count, source:, published_at: 1.hour.ago)
  end

  def answer(must_know:, for_you:, one_new_thing:, stretch:)
    JSON.generate({ must_know:, for_you:, one_new_thing:, stretch: })
  end

  test "turns a valid model answer into picks with the stretch flag set" do
    articles = candidates(7)
    ids = articles.map(&:id)
    stretch_id = ids[4]

    lambda_answer = answer(must_know: ids[0, 3], for_you: ids[3, 3],
                           one_new_thing: [ ids[6] ], stretch: stretch_id)
    assign = ->(payload) { assert payload.all? { _1.key?(:title) }; lambda_answer }

    picks = Briefly::Selector::Assign.call(articles, assign:)

    assert_equal 7, picks.size
    assert_equal %w[must_know must_know must_know for_you for_you for_you one_new_thing],
                 picks.map { _1[:section] }
    assert_equal [ stretch_id ], picks.select { _1[:stretch] }.map { _1[:article_id] }
  end

  test "falls back when the answer is not JSON" do
    articles = candidates(7)

    picks = Briefly::Selector::Assign.call(articles, assign: ->(_payload) { "thanks for the list!" })

    assert_equal 7, picks.size
  end

  test "falls back when the section counts are wrong" do
    articles = candidates(7)
    ids = articles.map(&:id)

    short = answer(must_know: ids[0, 2], for_you: ids[3, 3],
                   one_new_thing: [ ids[6] ], stretch: ids[4])

    picks = Briefly::Selector::Assign.call(articles, assign: ->(_payload) { short })

    assert_equal 7, picks.size
  end

  test "falls back when the model invents an id" do
    articles = candidates(7)
    ids = articles.map(&:id)

    invented = answer(must_know: ids[0, 2] + [ 999_999 ], for_you: ids[3, 3],
                      one_new_thing: [ ids[6] ], stretch: ids[4])

    picks = Briefly::Selector::Assign.call(articles, assign: ->(_payload) { invented })

    assert_equal 7, picks.size
  end

  test "falls back when the stretch id is not one of the for_you picks" do
    articles = candidates(7)
    ids = articles.map(&:id)

    wrong_stretch = answer(must_know: ids[0, 3], for_you: ids[3, 3],
                           one_new_thing: [ ids[6] ], stretch: ids[0])

    picks = Briefly::Selector::Assign.call(articles, assign: ->(_payload) { wrong_stretch })

    assert_equal 7, picks.size
    # The fallback always stretches the last for_you pick.
    assert_equal ids[5], picks.select { _1[:stretch] }[0][:article_id]
  end

  test "fallback fills what it can when there are fewer articles than slots" do
    articles = candidates(4)

    picks = Briefly::Selector::Assign.fallback(articles)

    assert_equal 4, picks.size
    assert_equal %w[must_know must_know must_know for_you], picks.map { _1[:section] }
    assert_equal articles.last.id, picks.last[:article_id]
    assert picks.last[:stretch]
  end
end
