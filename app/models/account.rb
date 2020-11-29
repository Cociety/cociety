class Account < ApplicationRecord
  belongs_to :owner, polymorphic: true, inverse_of: :account
  has_many :payments
  scope :customer, -> { where(owner_type: Customer.name) }
  scope :organization, -> { where(owner_type: Organization.name) }
end
