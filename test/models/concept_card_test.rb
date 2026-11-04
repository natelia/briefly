require "test_helper"

class ConceptCardTest < ActiveSupport::TestCase
  test "invalid without title and what_it_is" do
    card = build(:concept_card, title: nil, what_it_is: nil)
    assert_not card.valid?
    assert_includes card.errors[:title], "can't be blank"
    assert_includes card.errors[:what_it_is], "can't be blank"
  end

  test "series position only matters inside a series" do
    card = build(:concept_card, series_name: "How LLMs work", series_position: 2)
    assert card.valid?

    card = build(:concept_card, series_name: nil, series_position: 2)
    assert_not card.valid?
    assert_includes card.errors[:series_position], "needs a series name"
  end
end
