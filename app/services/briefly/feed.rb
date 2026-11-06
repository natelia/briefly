require "net/http"
require "uri"

module Briefly
  # Pulls every active source's feed and stores fresh articles.
  # One broken feed never stops the run: each source is isolated.
  class Feed
    class FetchError < StandardError; end

    REDIRECT_LIMIT = 3
    USER_AGENT = "briefly/0.1 (+https://github.com/natelia/briefly)"

    def self.fetch_all(since: 24.hours.ago, fetch: ->(url) { get(url) })
      Source.active.sum { |source| fetch_one(source, since:, fetch:) }
    end

    def self.fetch_one(source, since: 24.hours.ago, fetch: ->(url) { get(url) })
      import(source, fetch.call(source.feed_url), since:)
    rescue StandardError => e
      Rails.logger.warn("[briefly] #{source.name}: #{e.class} #{e.message}")
      0
    end

    # Stores entries published after `since`. URL is the identity of an
    # article: re-running the fetch always dedupes. Returns how many
    # NEW articles were stored.
    def self.import(source, xml, since: 24.hours.ago)
      parsed = Feedjira.parse(xml)
      fresh = parsed.entries.select { |entry| entry.published && entry.published > since }

      fresh.count do |entry|
        article = Article.find_or_initialize_by(url: entry.url)
        next if article.persisted?

        article.update!(source:, title: entry.title,
                        summary: entry.summary, published_at: entry.published)
        true
      end
    end

    # GET with a timeout, a User-Agent (some feeds 403 the default Ruby
    # one), and a redirect cap. Returns the response body.
    def self.get(url, redirects: REDIRECT_LIMIT)
      raise FetchError, "too many redirects for #{url}" if redirects.zero?

      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 5
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri, "User-Agent" => USER_AGENT)
      response = http.request(request)

      case response
      when Net::HTTPSuccess     then response.body
      when Net::HTTPRedirection then get(response["location"], redirects: redirects - 1)
      else raise FetchError, "HTTP #{response.code} for #{url}"
      end
    end
  end
end
