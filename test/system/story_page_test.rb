require_relative "application_system_test_case"

class StoryPageTest < ApplicationSystemTestCase
  test "story title opens the story page with source link" do
    story = create(:story,
      briefing: create(:briefing, date: Date.current),
      title: "Cloudflare outage postmortem",
      url: "https://blog.cloudflare.com/cloudflare-outage/",
      source_name: "blog.cloudflare.com",
      summary: "A bad config push broke DNS for an hour.",
      stretch: true,
      why_it_matters: "A stretch pick: small sites felt it first. Your side project lives on that edge.")

    visit root_url
    click_link "Cloudflare outage postmortem"

    assert_text "A bad config push broke DNS for an hour."
    assert_text "Why this matters for you:"
    assert_link "read the source", href: "https://blog.cloudflare.com/cloudflare-outage/"
    assert_link "back to the briefing"
  end
end
