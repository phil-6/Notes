class User < ApplicationRecord
  has_secure_password

  has_many :notes, dependent: :destroy
  has_many :shared_withs, dependent: :destroy
  has_many :shared_notes, through: :shared_withs, source: :note
  has_many :devices, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :display_name, presence: true
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?

  normalizes :email, with: ->(email) { email.strip.downcase }
end
