require_relative "application_system_test_case"

class ProgressTest < ApplicationSystemTestCase
  test "marking a story read updates progress and persists" do
    briefing = create(:briefing, date: Date.current)
    create(:story, briefing:, title: "Already read", read_at: Time.current)
    create(:story, briefing:, title: "Fresh story")

    visit root_url

    assert_text "1 of 2 read"
    within("article", text: "Fresh story") { click_button "Mark read" }

    assert_text "All 2 read — you're caught up, that's the whole internet for today."
    assert_no_button "Mark read"

    within("article", text: "Fresh story") { click_button "Mark unread" }
    assert_text "1 of 2 read"
    within("article", text: "Fresh story") { assert_button "Mark read" }

    within("article", text: "Fresh story") { click_button "Mark read" }
    assert_text "All 2 read — you're caught up, that's the whole internet for today."

    visit current_path
    assert_text "All 2 read — you're caught up, that's the whole internet for today."
    assert_no_button "Mark read"
  end
end
