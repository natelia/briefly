require_relative "application_system_test_case"

class QuizTest < ApplicationSystemTestCase
  test "correct answer shows explanation" do
    quiz = create(:quiz_question,
      question: "What does CDN stand for in the attack story?",
      options: [ "Content delivery network", "Credential data node", "Clustered disk nexus" ],
      answer_index: 0,
      explanation: "A CDN caches content close to readers.")

    visit briefing_path(quiz.briefing.date)

    within "section#check-in" do
      click_button "Content delivery network"
      assert_text "Right."
      assert_text "A CDN caches content close to readers."
    end
  end

  test "wrong answer is gentle" do
    quiz = create(:quiz_question,
      options: [ "Content delivery network", "Credential data node", "Clustered disk nexus" ],
      answer_index: 0,
      explanation: "A CDN caches content close to readers.")

    visit briefing_path(quiz.briefing.date)

    within "section#check-in" do
      click_button "Clustered disk nexus"
      assert_text "Not quite — A CDN caches content close to readers."
      assert_no_button "Content delivery network"
    end

    assert_no_text /fail|score|wrong/i
  end
end
