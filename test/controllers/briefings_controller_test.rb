require "test_helper"

class BriefingsControllerTest < ActionDispatch::IntegrationTest
  test "shows today's briefing on the root path" do
    Briefing.create!(date: Date.current)

    get root_url

    assert_response :success
    assert_match Date.current.strftime("%A"), response.body
  end

  test "shows the empty state when today has no briefing" do
    get root_url

    assert_response :success
    assert_match "Nothing here yet. Tomorrow's briefing builds overnight.", response.body
  end

  test "shows a specific date's briefing at its URL" do
    Briefing.create!(date: Date.new(2026, 10, 31))

    get briefing_url("2026-10-31")

    assert_response :success
    assert_match "Saturday", response.body
  end
end
