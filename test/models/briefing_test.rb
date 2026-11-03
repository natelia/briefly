require "test_helper"

class BriefingTest < ActiveSupport::TestCase
  test "is valid with a date" do
    briefing = Briefing.new(date: Date.new(2026, 11, 3))

    assert briefing.valid?
  end

  test "date must be unique" do
    Briefing.create!(date: Date.new(2026, 11, 3))
    duplicate = Briefing.new(date: Date.new(2026, 11, 3))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:date], "has already been taken"
  end

  test "for_date finds the briefing and returns nil when absent" do
    briefing = Briefing.create!(date: Date.new(2026, 11, 3))

    assert_equal briefing, Briefing.for_date(Date.new(2026, 11, 3))
    assert_nil Briefing.for_date(Date.new(2026, 11, 4))
  end
end
