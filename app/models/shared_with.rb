class SharedWith < ApplicationRecord
  belongs_to :note
  belongs_to :user

  validates :user_id, uniqueness: { scope: :note_id }

  scope :can_edit, -> { where(can_edit: true) }
  scope :read_only, -> { where(can_edit: false) }
end
