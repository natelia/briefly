class Story < ApplicationRecord
  belongs_to :briefing
  # Stories from the seed demo have no article — the link exists only for
  # stories the pipeline creates (M2 step 2).
  belongs_to :article, optional: true

  enum :section, { must_know: 0, for_you: 1, one_new_thing: 2 }

  validates :title, :summary, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  def read? = read_at.present?

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  def mark_unread!
    update!(read_at: nil) if read?
  end
end
