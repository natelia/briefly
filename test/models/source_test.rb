require "test_helper"

class SourceTest < ActiveSupport::TestCase
  test "is valid with name and feed_url" do
    assert build(:source).valid?
  end

  test "invalid without name or feed_url" do
    source = build(:source, name: nil, feed_url: nil)

    assert_not source.valid?
    assert_equal [ "can't be blank" ], source.errors[:name]
    assert_equal [ "can't be blank" ], source.errors[:feed_url]
  end

  test "rejects duplicate feed_url" do
    existing = create(:source, feed_url: "https://example.com/feed.xml")
    duplicate = build(:source, feed_url: existing.feed_url)

    assert_not duplicate.valid?
    assert_equal [ "has already been taken" ], duplicate.errors[:feed_url]
  end

  test "rejects a feed_url that is not http(s)" do
    assert_not build(:source, feed_url: "ftp://example.com/feed.xml").valid?
  end

  test ".active returns only active sources" do
    active = create(:source)
    create(:source, active: false)

    assert_equal [ active ], Source.active.to_a
  end
end
