# Handles payouts to organizations
class Payout
  attr_accessor :amount, :organization

  def initialize(amount, organization)
    @amount = amount
    @organization = organization
  end

  # Takes an array of customer charges and calculates how much to pay out to each organization
  def self.from_charges(charges, expenses_sum)
    ActiveRecord::Associations::Preloader.new.preload(charges, Charge.payment_allocations_association)
    payouts = {}
    charges.each do |charge|
      add_payout! payouts, charge
    end
    remove_expenses_from_payouts payouts, expenses_sum
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

  private_class_method def self.remove_expenses_from_payouts(payouts, expenses_sum)
    sum_of_payouts_not_accounting_for_expenses = payouts.values.map(&:amount).reduce(:+)
    sum_of_payouts = (sum_of_payouts_not_accounting_for_expenses - expenses_sum) * 0.40 # 40% of profits are donated
    return [] unless sum_of_payouts.positive?

    payouts.values.map do |p|
      percent_of_payout_to_organization = p.amount / sum_of_payouts_not_accounting_for_expenses
      p.amount = percent_of_payout_to_organization * sum_of_payouts
      p
    end
  end
end
