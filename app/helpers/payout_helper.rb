# Handles payouts to organizations
module PayoutHelper
  # Takes an array of customer charges and calculates how much to pay out to each organization
  def calculate_organization_payouts_from_charges(charges)
    preload_charge_associations charges
    payouts = {}
    charges.each do |c|
      customer_payment_allocations = c.customer.payment_allocations
      customer_payment_allocations.map do |a|
        amount = c.amount * a.percent / 100
        organization_id = a.organization.id
        payouts[organization_id] ||= 0
        payouts[organization_id] += amount
      end
    end
    payouts
  end

  def preload_charge_associations(charges)
    association = {
      customer: {
        payment_allocation_sets: {
          payment_allocations: :organization
        }
      }
    }
    ActiveRecord::Associations::Preloader.new.preload(charges, association)
  end
end
