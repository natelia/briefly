FactoryBot.define do
  factory :source do
    sequence(:name) { |n| "Source #{n}" }
    sequence(:feed_url) { |n| "https://example.com/feed-#{n}.xml" }
    active { true }
  end
end
