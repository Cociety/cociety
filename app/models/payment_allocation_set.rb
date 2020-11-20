class PaymentAllocationSet < ApplicationRecord
    belongs_to :customer
    has_many :payment_allocations, autosave: true
    validate :payment_percent_sum_to_100
    validates_associated :payment_allocations

    def payment_percent_sum
      payment_allocations.map { |a| a.percent }.reduce(:+)
    end

    private

    def payment_percent_sum_to_100
        errors[:base] << "payment percentages must add to 100" unless payment_percent_sum == 100
    end
end
