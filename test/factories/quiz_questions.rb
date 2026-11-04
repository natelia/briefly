FactoryBot.define do
  factory :quiz_question do
    briefing
    question { "What did the story say mattered?" }
    options { [ "First option", "Second option" ] }
    answer_index { 0 }
    explanation { "It mattered because the summary said so." }
  end
end
