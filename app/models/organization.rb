class Organization < ApplicationRecord
  has_and_belongs_to_many :organization_categories
  has_many :payment_allocations
  validates :name, length: { minimum: 1 }
  validates :description, length: { minimum: 1 }
  validates :url, presence: true, secure_url: true
  validates :organization_categories, length: { minimum: 1 }
end
