class Connection < ApplicationRecord
  belongs_to :user_1, class_name: "User"
  belongs_to :user_2, class_name: "User"

  validates :user_1_id, uniqueness: { scope: :user_2_id }
  validates :status, inclusion: { in: %w[pending accepted rejected] }
  validate :users_cannot_be_the_same

  scope :pending, -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }
  scope :rejected, -> { where(status: "rejected") }

  def accept!
    update!(status: "accepted")
  end

  def reject!
    update!(status: "rejected")
  end

  def pending?
    status == "pending"
  end

  def accepted?
    status == "accepted"
  end

  private
  def users_cannot_be_the_same
    errors.add(:user_2_id, "cannot be the same as user_1") if user_1_id == user_2_id
  end
end
