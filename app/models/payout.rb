# Handles payouts to organizations
class Payout
  attr_accessor :amount, :organization

  def initialize(amount, organization)
    @amount = amount
    @organization = organization
  end

  # Takes an array of customer charges and calculates how much to pay out to each organization
  def self.from_charges(charges)
    preload_charge_associations charges
    payouts = {}
    charges.each do |charge|
      add_payout! payouts, charge
    end
    payouts
  end

  private_class_method def self.add_payout!(payouts, charge)
    customer_payment_allocations = charge.customer.payment_allocations
    customer_payment_allocations.map do |payment_allocation|
      amount = charge.amount * payment_allocation.percent / 100
      organization = payment_allocation.organization
      payouts[organization.id] ||= new(0, organization)
      payouts[organization.id].amount += amount
    end
  end

  private_class_method def self.preload_charge_associations(charges)
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
