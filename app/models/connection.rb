class Connection < ApplicationRecord
  belongs_to :user_1, class_name: "User"
  belongs_to :user_2, class_name: "User"

  validates :user_1_id, uniqueness: { scope: :user_2_id }
  validate :users_cannot_be_the_same

  private
  def users_cannot_be_the_same
    errors.add(:user_2_id, "cannot be the same as user_1") if user_1_id == user_2_id
  end
end
