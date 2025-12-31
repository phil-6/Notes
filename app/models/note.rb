class Note < ApplicationRecord
  belongs_to :user
  belongs_to :locked_by, class_name: "User", optional: true

  has_rich_text :content
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :shared_withs, dependent: :destroy
  has_many :shared_with_users, through: :shared_withs, source: :user
  has_many :versions, class_name: "NoteVersion", dependent: :destroy

  COLORS = %w[
    default slate gray zinc stone red orange amber yellow lime green emerald
    teal cyan sky blue indigo violet purple fuchsia pink rose
  ].freeze

  LOCK_TIMEOUT = 5.minutes

  validates :color, inclusion: { in: COLORS, allow_nil: true }

  scope :pinned, -> { where(pinned: true) }
  scope :unpinned, -> { where(pinned: false) }

  before_save :set_default_color, if: :new_record?
  after_create :create_initial_version
  after_update :create_version_on_update, unless: :skip_versioning?

  attr_accessor :skip_versioning, :version_user

  def restore_version(version)
    self.skip_versioning = true
    update(
      title: version.title,
      color: version.color
    )
    self.content = version.content if version.content.present?
    save
    create_version("restored")
    self.skip_versioning = false
  end

  def current_version_number
    versions.maximum(:version_number) || 0
  end

  # Locking methods
  def lock!(user)
    update(locked_by: user, locked_at: Time.current)
  end

  def unlock!
    update(locked_by: nil, locked_at: nil)
  end

  def locked?
    locked_by_id.present? && locked_at.present? && locked_at > LOCK_TIMEOUT.ago
  end

  def locked_by?(user)
    locked? && locked_by_id == user.id
  end

  def can_be_edited_by?(user)
    return true if user_id == user.id # Owner can always edit
    return false unless locked? || !locked_by?(user) # Can't edit if locked by someone else

    shared_with = shared_withs.find_by(user: user)
    shared_with&.can_edit? || false
  end

  def editable_by?(user)
    return true if user_id == user.id
    !locked? || locked_by?(user)
  end

  private
  def set_default_color
    self.color ||= "default"
  end

  def skip_versioning?
    skip_versioning == true
  end

  def create_initial_version
    create_version("created")
  end

  def create_version_on_update
    return unless saved_change_to_title? || saved_change_to_color? || content.body.present?
    create_version("updated")
  end

  def create_version(change_type)
    versions.create!(
      title: title,
      content: content.to_plain_text,
      color: color,
      version_number: current_version_number + 1,
      change_type: change_type,
      created_by: version_user || user
    )
  end
end
