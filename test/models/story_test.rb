require "test_helper"

class StoryTest < ActiveSupport::TestCase
  test "is valid with title, summary, and section" do
    assert build(:story, section: :must_know).valid?
  end

  test "section enum exposes the three sections" do
    story = build(:story, section: :one_new_thing)

    assert_equal "one_new_thing", story.section
    assert_equal 2, Story.sections[:one_new_thing]
  end

  test "invalid without title or summary" do
    story = build(:story, title: nil, summary: nil)

    assert_not story.valid?
    assert_equal [ "can't be blank" ], story.errors[:title]
    assert_equal [ "can't be blank" ], story.errors[:summary]
  end

  test "requires a briefing" do
    story = build(:story, briefing: nil)

    assert_not story.valid?
  end

  test "starts unread and mark_read! sets read_at once" do
    story = create(:story, section: :for_you)
    assert_not story.read?

    story.mark_read!
    first_read_at = story.read_at

    story.mark_read!
    assert_equal first_read_at, story.reload.read_at
  end

  test "unread scope excludes read stories" do
    briefing = create(:briefing)
    read_story = create(:story, briefing:, title: "Read")
    read_story.update!(read_at: Time.current)
    create(:story, briefing:, title: "Unread")

    assert_equal 1, briefing.stories.unread.count
  end
  test "mark_unread reverts a read story and stays idempotent" do
    story = create(:story, read_at: Time.current)
    story.mark_unread!
    assert_not story.reload.read?

    story.mark_unread!
    assert_not story.reload.read?
  end
end
