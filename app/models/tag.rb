class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :notes, through: :taggings

  validates :name, presence: true, uniqueness: true

  normalizes :name, with: ->(name) { name.strip.downcase }
end
