require "test_helper"

class Briefly::WriterTest < ActiveSupport::TestCase
  test "rewrites the summaries from the model answer" do
    briefing = create(:briefing)
    stretch = create(:story, briefing:, section: :for_you, stretch: true)
    plain = create(:story, briefing:, summary: "Old summary.")
    answer = JSON.generate([
      { id: plain.id, headline: "A plain headline.",
        summary: "New summary for the plain story.",
        digest: "First paragraph with detail.\n\nSecond paragraph." },
      { id: stretch.id, summary: "A stretch pick: something new.",
        why_it_matters: "It changes how you design components." }
    ])

    count = Briefly::Writer.call(briefing, complete: ->(_prompt) { answer })

    assert_equal 2, count
    assert_equal "A plain headline.", plain.reload.headline
    assert_equal "New summary for the plain story.", plain.reload.summary
    assert_equal "First paragraph with detail.\n\nSecond paragraph.", plain.reload.digest
    assert_nil stretch.reload.digest
    assert_equal "A stretch pick: something new.", stretch.reload.summary
    assert_equal "It changes how you design components.", stretch.reload.why_it_matters
  end

  test "skips an oversized digest but keeps the summary" do
    briefing = create(:briefing)
    story = create(:story, briefing:, summary: "Old summary.")
    answer = JSON.generate([
      { id: story.id, summary: "Short teaser.", digest: "x" * 2001 }
    ])

    Briefly::Writer.call(briefing, complete: ->(_p) { answer })

    assert_equal "Short teaser.", story.reload.summary
    assert_nil story.reload.digest
  end

  test "skips an oversized headline but keeps the summary" do
    briefing = create(:briefing)
    story = create(:story, briefing:, summary: "Old summary.")
    answer = JSON.generate([
      { id: story.id, summary: "Short teaser.", headline: "h" * 121 }
    ])

    Briefly::Writer.call(briefing, complete: ->(_p) { answer })

    assert_equal "Short teaser.", story.reload.summary
    assert_nil story.reload.headline
  end

  test "display_title falls back to the feed title without a headline" do
    story = create(:story, title: "Feed Title", headline: nil)

    assert_equal "Feed Title", story.display_title

    story.update!(headline: "Plain headline")
    assert_equal "Plain headline", story.display_title
  end

  test "skips answers with unknown ids or empty summaries" do
    briefing = create(:briefing)
    story = create(:story, briefing:, summary: "Old summary.")
    answer = JSON.generate([
      { id: story.id + 100, summary: "A ghost story." },
      { id: story.id, summary: "   " }
    ])

    assert_equal 0, Briefly::Writer.call(briefing, complete: ->(_p) { answer })
    assert_equal "Old summary.", story.reload.summary
  end

  test "keeps placeholders when the model fails" do
    briefing = create(:briefing)
    story = create(:story, briefing:, summary: "Old summary.")

    assert_equal 0, Briefly::Writer.call(briefing, complete: ->(_p) { "not json" })
    assert_equal 0, Briefly::Writer.call(briefing, complete: ->(_p) { raise "boom" })
    assert_equal "Old summary.", story.reload.summary
  end

  test "does nothing for an empty briefing" do
    briefing = create(:briefing)

    assert_equal 0, Briefly::Writer.call(briefing, complete: ->(_p) { flunk })
  end

  test "the prompt carries the stories and the style contract" do
    briefing = create(:briefing)
    story = create(:story, briefing:, section: :one_new_thing)
    asked = nil
    complete = ->(prompt) { asked = prompt; "[]" }

    Briefly::Writer.call(briefing, complete:)

    assert_includes asked, "one_new_thing"
    assert_includes asked, story.id.to_s
    assert_includes asked, "A stretch pick"
    assert_includes asked, "digest"
    assert_includes asked, "headline"
  end
end
