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

  def previous_version
    note.versions.where("version_number < ?", version_number).order(version_number: :desc).first
  end

  def changes_from_previous
    return {} unless previous_version

    changes = {}
    changes[:title] = [previous_version.title, title] if previous_version.title != title
    changes[:color] = [previous_version.color, color] if previous_version.color != color
    changes[:content] = [previous_version.content, content] if previous_version.content != content
    changes
  end
end
