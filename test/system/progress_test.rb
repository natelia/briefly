require_relative "application_system_test_case"

class ProgressTest < ApplicationSystemTestCase
  test "marking a story read updates progress and persists" do
    briefing = create(:briefing, date: Date.current)
    create(:story, briefing:, title: "Already read", read_at: Time.current)
    create(:story, briefing:, title: "Fresh story")

    visit root_url

    assert_text "1 of 2 read"
    within("article", text: "Fresh story") { click_button "Mark read" }

    assert_text "2 of 2 read"
    assert_no_button "Mark read"

    visit current_path
    assert_text "2 of 2 read"
    assert_no_button "Mark read"
  end
end
