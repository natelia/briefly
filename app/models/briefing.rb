class Briefing < ApplicationRecord
  has_many :stories, dependent: :destroy

  validates :date, presence: true, uniqueness: true

  def self.for_date(date) = find_by(date: date)

  def read_fraction
    total = stories.size
    return Rational(1) if total.zero?

    Rational(stories.read.count, total)
  end
end
