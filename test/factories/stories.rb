FactoryBot.define do
  factory :story do
    briefing
    section { :must_know }
    sequence(:title) { |n| "Story ##{n}" }
    source_name { "Example Source" }
    url { "https://example.com/story" }
    sequence(:summary) { |n| "Summary ##{n} of the story." }
    published_at { 2.days.ago }

    trait :for_you do
      section { :for_you }
    end

    trait :one_new_thing do
      section { :one_new_thing }
    end

    trait :stretch do
      stretch { true }
      why_it_matters { "Why this matters for you." }
    end
  end
end
