FactoryBot.define do
  factory :article do
    source
    sequence(:title) { |n| "Article #{n}" }
    sequence(:url) { |n| "https://example.com/post-#{n}" }
    summary { "The raw summary from the feed, long enough to count as substance for the selector." }
    published_at { 2.hours.ago }
  end
end
