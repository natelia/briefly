class Article < ApplicationRecord
  belongs_to :source

  validates :title, :url, presence: true
  validates :url, uniqueness: true

  scope :since, ->(time) { where("published_at > ?", time) }
  scope :recent_first, -> { order(published_at: :desc) }
end
