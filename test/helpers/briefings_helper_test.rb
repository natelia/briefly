require "test_helper"

class BriefingsHelperTest < ActionView::TestCase
  test "greeting follows the hour" do
    assert_equal "Good morning, Natalia.", greeting(Time.new(2026, 11, 3, 7, 40))
    assert_equal "Good afternoon, Natalia.", greeting(Time.new(2026, 11, 3, 15, 0))
    assert_equal "Good evening, Natalia.", greeting(Time.new(2026, 11, 3, 21, 0))
  end
end
