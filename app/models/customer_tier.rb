class CustomerTier < ApplicationRecord
  before_validation :set_default_effective_date
  belongs_to :tier
  belongs_to :customer
  default_scope -> { order(created_at: :desc) }
  scope :active, ->(time = Time.now) { where('effective < ? AND ? > expiration', time, time) }
  validate :effective_time_must_not_overlap_exisiting_tier

  private

  def effective_time_must_not_overlap_exisiting_tier
    overlapping_tiers = CustomerTier.active(effective)
                                    .or(CustomerTier.active(expiration))
                                    .where(customer_id: customer_id)

    return if overlapping_tiers.count.zero?

    errors.add(:effective_range, "time window from effective to expiration can't overlap an existing customer tier")
  end

  def set_default_effective_date
    self.effective ||= Time.now
  end
end
