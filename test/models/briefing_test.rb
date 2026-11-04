require "test_helper"

class BriefingTest < ActiveSupport::TestCase
  test "is valid with a date" do
    assert build(:briefing).valid?
  end

  test "date must be unique" do
    create(:briefing, date: Date.new(2026, 11, 3))
    duplicate = build(:briefing, date: Date.new(2026, 11, 3))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:date], "has already been taken"
  end

  test "for_date finds the briefing and returns nil when absent" do
    briefing = create(:briefing, date: Date.new(2026, 11, 3))

    assert_equal briefing, Briefing.for_date(Date.new(2026, 11, 3))
    assert_nil Briefing.for_date(Date.new(2026, 11, 4))
  end

  test "before and after find the neighbouring briefings" do
    older = create(:briefing, date: Date.new(2026, 11, 2))
    create(:briefing, date: Date.new(2026, 11, 3))
    newer = create(:briefing, date: Date.new(2026, 11, 5))

    assert_equal older, Briefing.before(Date.new(2026, 11, 3))
    assert_equal newer, Briefing.after(Date.new(2026, 11, 3))
    assert_nil Briefing.before(Date.new(2026, 11, 2))
  end

  test "read_fraction reports caught-up states" do
    empty = create(:briefing)
    assert_equal Rational(1), empty.read_fraction

    partial = create(:briefing)
    create(:story, briefing: partial, read_at: Time.current)
    create(:story, briefing: partial)
    assert_equal Rational(1, 2), partial.read_fraction

    full = create(:briefing)
    create(:story, briefing: full, read_at: Time.current)
    create(:story, briefing: full, read_at: Time.current)
    assert_equal Rational(1), full.read_fraction
  end
end
