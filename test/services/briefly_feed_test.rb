require "test_helper"

class Briefly::FeedTest < ActiveSupport::TestCase
  RSS_XML = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
      <channel>
        <title>Example Engineering</title>
        <item>
          <title>Postgres ships incremental backup</title>
          <link>https://example.com/postgres-incremental-backup</link>
          <description>The database can now send only the changed pages.</description>
          <pubDate>#{3.hours.ago.rfc822}</pubDate>
        </item>
        <item>
          <title>An old post from last week</title>
          <link>https://example.com/old-post</link>
          <description>Published outside the fetch window.</description>
          <pubDate>#{3.days.ago.rfc822}</pubDate>
        </item>
        <item>
          <title>Postgres ships incremental backup</title>
          <link>https://example.com/postgres-incremental-backup</link>
          <description>The same URL appears twice — dedup must hold.</description>
          <pubDate>#{2.hours.ago.rfc822}</pubDate>
        </item>
      </channel>
    </rss>
  XML

  ATOM_XML = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>Example Atom</title>
      <entry>
        <title>Atom entry about CRDTs</title>
        <link href="https://example.net/crdts" rel="alternate"/>
        <summary>Merging without a central judge.</summary>
        <published>#{1.hour.ago.iso8601}</published>
      </entry>
    </feed>
  XML

  test ".import stores only fresh RSS entries, deduped by url" do
    source = create(:source)

    stored = Briefly::Feed.import(source, RSS_XML, since: 24.hours.ago)

    assert_equal 1, stored
    article = Article.find_by!(url: "https://example.com/postgres-incremental-backup")
    assert_equal source, article.source
    assert_equal "Postgres ships incremental backup", article.title
    assert_nil Article.find_by(url: "https://example.com/old-post")
  end

  test ".import is idempotent: re-running stores nothing new" do
    source = create(:source)
    Briefly::Feed.import(source, RSS_XML, since: 24.hours.ago)

    assert_equal 0, Briefly::Feed.import(source, RSS_XML, since: 24.hours.ago)
    assert_equal 1, source.articles.count
  end

  test ".import skips entries without a url instead of aborting the batch" do
    source = create(:source)
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Partial Feed</title>
          <item>
            <title>Entry with no link</title>
            <description>Real feeds sometimes ship these.</description>
            <pubDate>#{1.hour.ago.rfc822}</pubDate>
          </item>
          <item>
            <title>Entry with a link</title>
            <link>https://example.com/with-link</link>
            <pubDate>#{1.hour.ago.rfc822}</pubDate>
          </item>
        </channel>
      </rss>
    XML

    assert_equal 1, Briefly::Feed.import(source, xml, since: 24.hours.ago)
    assert Article.find_by!(url: "https://example.com/with-link")
  end

  test ".import understands Atom feeds" do
    source = create(:source)

    stored = Briefly::Feed.import(source, ATOM_XML, since: 24.hours.ago)

    assert_equal 1, stored
    assert Article.find_by!(url: "https://example.net/crdts")
  end

  test ".fetch_one returns 0 and logs when a feed is unreachable" do
    source = create(:source)
    failing = ->(_url) { raise Briefly::Feed::FetchError, "HTTP 500" }

    assert_equal 0, Briefly::Feed.fetch_one(source, fetch: failing)
  end

  test ".fetch_one returns 0 when a feed serves garbage" do
    source = create(:source)
    garbage = ->(_url) { "this is not xml" }

    assert_equal 0, Briefly::Feed.fetch_one(source, fetch: garbage)
  end

  test ".fetch_all skips inactive sources and survives a broken one" do
    good = create(:source, feed_url: "https://example.com/good.xml")
    create(:source, feed_url: "https://example.com/broken.xml")
    create(:source, feed_url: "https://example.com/off.xml", active: false)

    fetch = ->(url) do
      url.include?("broken") ? raise(Briefly::Feed::FetchError, "HTTP 503") : RSS_XML
    end

    assert_equal 1, Briefly::Feed.fetch_all(since: 24.hours.ago, fetch:)
    assert_equal 1, good.articles.count
  end
end
