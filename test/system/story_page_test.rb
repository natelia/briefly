require_relative "application_system_test_case"

class StoryPageTest < ApplicationSystemTestCase
  test "story title opens the story page with source link" do
    story = create(:story,
      briefing: create(:briefing, date: Date.current),
      title: "Cloudflare outage postmortem",
      url: "https://blog.cloudflare.com/cloudflare-outage/",
      source_name: "blog.cloudflare.com",
      summary: "A bad config push broke DNS for an hour.",
      digest: "One paragraph of the real story. The failure was amplification.",
      stretch: true,
      why_it_matters: "A stretch pick: small sites felt it first. Your side project lives on that edge.")

    visit root_url
    click_link "Cloudflare outage postmortem"

    assert_text "One paragraph of the real story. The failure was amplification." # the digest, not the card's one-liner
    assert_text "Why this matters for you:"
    assert_link "read the source", href: "https://blog.cloudflare.com/cloudflare-outage/"
    assert_link "back to the briefing"
  end

  test "marking read from the story page updates the briefing" do
    story = create(:story, briefing: create(:briefing, date: Date.current))

    visit story_path(story)
    click_button "Mark read"

    assert_no_button "Mark read"
    assert_text "read"

    visit root_url
    within("article", text: story.title) { assert_text "read" }
  end
end
