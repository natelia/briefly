require "test_helper"

class StoryTest < ActiveSupport::TestCase
  def build_story(attributes = {})
    briefing = Briefing.create!(date: Date.new(2026, 11, 3))
    Story.new(briefing:, title: "npm supply-chain attack", summary: "Popular packages were hijacked overnight.", **attributes)
  end

  test "is valid with title, summary, and section" do
    story = build_story(section: :must_know)

    assert story.valid?
  end

  test "section enum exposes the three sections" do
    story = build_story(section: :one_new_thing)

    assert_equal "one_new_thing", story.section
    assert_equal 2, Story.sections[:one_new_thing]
  end

  test "invalid without title or summary" do
    story = build_story(title: nil, summary: nil)

    assert_not story.valid?
    assert_equal ["can't be blank"], story.errors[:title]
    assert_equal ["can't be blank"], story.errors[:summary]
  end

  test "requires a briefing" do
    story = build_story(briefing: nil)

    assert_not story.valid?
  end

  test "starts unread and mark_read! sets read_at once" do
    story = build_story(section: :for_you)
    story.save!
    assert_not story.read?

    story.mark_read!
    first_read_at = story.read_at

    story.mark_read!
    assert_equal first_read_at, story.reload.read_at
  end

  test "unread scope excludes read stories" do
    briefing = Briefing.create!(date: Date.new(2026, 11, 3))
    read_story = briefing.stories.create!(title: "Read", summary: "s", section: :must_know)
    read_story.update!(read_at: Time.current)
    briefing.stories.create!(title: "Unread", summary: "s", section: :must_know)

    assert_equal 1, briefing.stories.unread.count
  end
end
