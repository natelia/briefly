require_relative "application_system_test_case"

class ConceptCardFlowTest < ApplicationSystemTestCase
  test "card strip links to card page" do
    card = create(:concept_card,
      briefing: create(:briefing, date: Date.current),
      title: "Container queries",
      domain: "css",
      what_it_is: "Rules that size elements by their container, not the viewport.",
      how_it_works: "A container declares itself; children query its width and adapt.",
      why_you_care: "Components become portable between sidebars and full pages.",
      deeper_link: "https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment")

    visit root_url

    assert_text "Container queries"

    click_link "Container queries"

    assert_text "Rules that size elements by their container, not the viewport."
    assert_text "A container declares itself; children query its width and adapt."
    assert_text "Components become portable between sidebars and full pages."
    assert_link "go deeper", href: "https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment"
  end
end
