require "test_helper"

class QuizQuestionTest < ActiveSupport::TestCase
  test "valid with two to four options and answer in range" do
    [ 2, 3, 4 ].each do |n|
      quiz = build(:quiz_question, options: Array.new(n) { |i| "Option #{i}" }, answer_index: n - 1)
      assert quiz.valid?, "expected #{n} options to be valid"
    end
  end

  test "invalid outside two to four options" do
    quiz = build(:quiz_question, options: [ "Only one" ])
    assert_not quiz.valid?
    assert_includes quiz.errors[:options], "needs between 2 and 4 options"

    quiz = build(:quiz_question, options: Array.new(5) { |i| "Option #{i}" })
    assert_not quiz.valid?
    assert_includes quiz.errors[:options], "needs between 2 and 4 options"
  end

  test "answer index stays within the options" do
    quiz = build(:quiz_question, answer_index: -1)
    assert_not quiz.valid?
    assert_includes quiz.errors[:answer_index], "points outside the options"

    quiz = build(:quiz_question, answer_index: 2)
    assert_not quiz.valid?
    assert_includes quiz.errors[:answer_index], "points outside the options"
  end

  test "correct? compares the choice to the answer index" do
    quiz = create(:quiz_question, options: [ "A", "B", "C" ], answer_index: 1)
    assert quiz.correct?(1)
    assert_not quiz.correct?(0)
  end
end
