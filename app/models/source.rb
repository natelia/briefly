class Source < ApplicationRecord
  has_many :articles, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :feed_url, presence: true, uniqueness: true
  validates :feed_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[ http https ]),
                                 message: "must be an http(s) URL",
                                 allow_nil: true }

  scope :active, -> { where(active: true) }
end
