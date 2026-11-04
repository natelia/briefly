class ConceptCard < ApplicationRecord
  belongs_to :briefing

  validates :title, :what_it_is, presence: true
  validate :series_position_needs_series

  private

  def series_position_needs_series
    errors.add(:series_position, "needs a series name") if series_position.present? && series_name.blank?
  end
end
