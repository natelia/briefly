FactoryBot.define do
  factory :briefing do
    sequence(:date) { |n| Date.new(2026, 1, 1) + n }
  end
end
