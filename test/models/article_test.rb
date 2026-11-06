require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "is valid with source, title, and url" do
    assert build(:article).valid?
  end

  test "invalid without title or url" do
    article = build(:article, title: nil, url: nil)

    assert_not article.valid?
    assert_equal [ "can't be blank" ], article.errors[:title]
    assert_equal [ "can't be blank" ], article.errors[:url]
  end

  test "rejects duplicate url" do
    existing = create(:article, url: "https://example.com/post")
    duplicate = build(:article, url: existing.url)

    assert_not duplicate.valid?
    assert_equal [ "has already been taken" ], duplicate.errors[:url]
  end

  test "requires a source" do
    assert_not build(:article, source: nil).valid?
  end
end
