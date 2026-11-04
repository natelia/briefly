FactoryBot.define do
  factory :concept_card do
    briefing
    title { "Vector database" }
    domain { "databases" }
    what_it_is { "A store that searches by meaning, not exact match." }
    how_it_works { "Text becomes a list of numbers; nearby numbers mean nearby ideas." }
    why_you_care { "It is how search answers questions instead of keywords." }
    deeper_link { "https://example.com/deeper" }
  end
end
