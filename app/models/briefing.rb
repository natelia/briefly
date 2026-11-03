class Briefing < ApplicationRecord
  has_many :stories, dependent: :destroy

  validates :date, presence: true, uniqueness: true

  def self.for_date(date) = find_by(date: date)
end
