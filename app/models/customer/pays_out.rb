module Customer::PaysOut
  extend ActiveSupport::Concern
  included do
    after_create :split_payout_between_all_organizations
    has_many :payment_allocation_sets, autosave: true
    def payment_allocations
      payment_allocation_sets&.first&.payment_allocations || []
    end

    def payment_allocations_for_all_organizations
      p = payment_allocations
      o_donated_to = p.map(&:organization_id)
      o_not_donated_to = Organization.where.not(id: o_donated_to)
      o_not_donated_to.each do |o|
        p.push PaymentAllocation.new(percent: 0, organization: o)
      end
      p
    end
  end

  private

  def split_payout_between_all_organizations
    o_ids = Organization.pluck(:id)
    return if o_ids.empty?

    pas = payment_allocation_sets.create(payment_allocations: to_payment_allocations(o_ids))
    pas.force_sum_to_100
    pas.save!
  end

  def to_payment_allocations(o_ids)
    percent = 100 / o_ids.size
    o_ids.map do |o_id|
      PaymentAllocation.new(
        percent:         percent,
        organization_id: o_id
      )
    end
  end
end
