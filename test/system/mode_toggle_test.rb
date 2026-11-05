require_relative "application_system_test_case"

class ModeToggleTest < ApplicationSystemTestCase
  test "toggle flips and persists the color mode" do
    create(:briefing, date: Date.current)
    visit root_url

    assert_selector "html:not([data-mode])" # starts on the system preference

    click_button "dark"
    assert_selector "html[data-mode='dark']"

    visit current_url
    assert_selector "html[data-mode='dark']" # survives reload via localStorage

    click_button "light"
    assert_selector "html[data-mode='light']"
  end
end
