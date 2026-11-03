class Story < ApplicationRecord
  belongs_to :briefing

  enum :section, { must_know: 0, for_you: 1, one_new_thing: 2 }

  validates :title, :summary, presence: true

  scope :unread, -> { where(read_at: nil) }

  def read? = read_at.present?

  def mark_read!
    update!(read_at: Time.current) unless read?
  end
end
