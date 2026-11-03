require_relative "application_system_test_case"

class BriefingSectionsTest < ApplicationSystemTestCase
  test "all sections render their stories" do
    briefing = create(:briefing, date: Date.current)
    create(:story, briefing:, title: "npm supply-chain attack")
    create(:story, :for_you, :stretch, briefing:, title: "CSS container queries")
    create(:story, :one_new_thing, briefing:, title: "CRDTs explained")

    visit root_url

    within "section#must-know" do
      assert_text "npm supply-chain attack"
      assert_no_text "Why this matters for you"
    end

    within "section#for-you" do
      assert_text "CSS container queries"
      assert_text "Why this matters for you"
    end

    within "section#one-new-thing" do
      assert_text "CRDTs explained"
    end
  end
end
