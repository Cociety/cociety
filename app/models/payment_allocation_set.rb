class PaymentAllocationSet < ApplicationRecord
  belongs_to :customer
  before_validation :filter_zero_percent_payment_allocations
  default_scope -> { order(created_at: :desc) }
  has_many :payment_allocations, autosave: true
  validate :sums_to_100
  validates_associated :payment_allocations

  def force_sum_to_100
    return if payment_allocations.empty?

    payment_allocations.first.percent += (100 - sum) if sum != 100
  end

  def sum
    payment_allocations.map(&:percent).reduce(:+)
  end

  private

  def filter_zero_percent_payment_allocations
    self.payment_allocations = payment_allocations.select { |p| p.percent.nonzero? }
  end

  def sums_to_100
    errors.add :base, I18n.t(:payment_percentages_must_sum_to_100) unless sum == 100
  end
end
