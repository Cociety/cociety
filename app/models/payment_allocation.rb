class PaymentAllocation < ApplicationRecord
  belongs_to :payment_allocation_set
  belongs_to :organization
  validates :percent, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
end
