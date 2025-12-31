class Note < ApplicationRecord
  belongs_to :user

  has_rich_text :content
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :shared_withs, dependent: :destroy
  has_many :shared_with_users, through: :shared_withs, source: :user

  validates :color, inclusion: { in: %w[default yellow red blue green], allow_nil: true }

  scope :pinned, -> { where(pinned: true) }
  scope :unpinned, -> { where(pinned: false) }

  before_save :set_default_color, if: :new_record?

  private
  def set_default_color
    self.color ||= "default"
  end
end
