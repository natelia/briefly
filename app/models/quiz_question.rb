class QuizQuestion < ApplicationRecord
  belongs_to :briefing

  validates :question, :explanation, presence: true
  validate :options_size
  validate :answer_index_within_options

  def correct?(choice) = choice == answer_index

  private

  def options_size
    errors.add(:options, "needs between 2 and 4 options") unless options.is_a?(Array) && options.size.between?(2, 4)
  end

  def answer_index_within_options
    return unless options.is_a?(Array) && options.size.between?(2, 4)

    errors.add(:answer_index, "points outside the options") unless answer_index.between?(0, options.size - 1)
  end
end
