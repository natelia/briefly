class Briefing < ApplicationRecord
  has_many :stories, dependent: :destroy
  has_many :quiz_questions, dependent: :destroy

  validates :date, presence: true, uniqueness: true

  def self.for_date(date) = find_by(date: date)

  def self.before(date) = where("date < ?", date).order(date: :desc).first
  def self.after(date)  = where("date > ?", date).order(:date).first

  def read_fraction
    total = stories.size
    return Rational(1) if total.zero?

    Rational(stories.read.count, total)
  end
end
