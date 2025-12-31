class NoteVersion < ApplicationRecord
  belongs_to :note
  belongs_to :created_by, class_name: "User"

  validates :version_number, presence: true, uniqueness: { scope: :note_id }
  validates :change_type, inclusion: { in: %w[created updated restored shared unshared] }

  scope :ordered, -> { order(version_number: :desc) }

  def created_by_name
    created_by.display_name
  end

  def restore_to_note
    note.restore_version(self)
  end
end
