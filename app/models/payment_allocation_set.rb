class PaymentAllocationSet < ApplicationRecord
  belongs_to :customer
  before_validation :filter_zero_percent_payment_allocations
  default_scope -> { order(created_at: :desc) }
  has_many :payment_allocations, autosave: true
  validate :payment_percent_sum_to_100
  validates_associated :payment_allocations

  def payment_percent_sum
    payment_allocations.map(&:percent).reduce(:+)
  end

  private

  def filter_zero_percent_payment_allocations
    self.payment_allocations = payment_allocations.select { |p| p.percent.nonzero? }
  end

  def payment_percent_sum_to_100
    errors.add :base, I18n.t(:payment_percentages_must_sum_to_100) unless payment_percent_sum == 100
  end
end
