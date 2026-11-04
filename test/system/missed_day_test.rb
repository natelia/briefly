require_relative "application_system_test_case"

class MissedDayTest < ApplicationSystemTestCase
  test "band shown when yesterday unread" do
    yesterday = create(:briefing, date: Date.yesterday)
    create(:story, briefing: yesterday, title: "The one that mattered", read_at: Time.current)
    create(:story, briefing: yesterday, title: "The unread one")
    create(:briefing, date: Date.current)

    visit root_url

    assert_text "You skipped #{Date.yesterday.strftime("%A")}. Nothing stacked — one thing mattered: The unread one"
    assert_link "The unread one", href: briefing_path(date: Date.yesterday)
    assert_no_button "catch up"
  end

  test "band hidden when yesterday read or missing" do
    read_day = create(:briefing, date: Date.yesterday)
    create(:story, briefing: read_day, title: "All done here", read_at: Time.current)
    create(:briefing, date: Date.current)

    visit root_url
    assert_no_text "You skipped"

    read_day.destroy

    visit root_url
    assert_no_text "You skipped"
  end
end
