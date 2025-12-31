class User < ApplicationRecord
  has_secure_password

  has_many :notes, dependent: :destroy
  has_many :shared_withs, dependent: :destroy
  has_many :shared_notes, through: :shared_withs, source: :note
  has_many :devices, dependent: :destroy

  has_many :initiated_connections, class_name: "Connection", foreign_key: "user_1_id", dependent: :destroy
  has_many :received_connections, class_name: "Connection", foreign_key: "user_2_id", dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :display_name, presence: true
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?

  normalizes :email, with: ->(email) { email.strip.downcase }

  def connections
    Connection.accepted.where("user_1_id = ? OR user_2_id = ?", id, id)
  end

  def connected_users
    connection_ids = connections.pluck(:user_1_id, :user_2_id).flatten.uniq - [ id ]
    User.where(id: connection_ids)
  end

  def pending_connection_requests
    received_connections.pending
  end

  def connected_with?(other_user)
    connections.exists?([ "(user_1_id = ? AND user_2_id = ?) OR (user_1_id = ? AND user_2_id = ?)", id, other_user.id, other_user.id, id ])
  end
end
