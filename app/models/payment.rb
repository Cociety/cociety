class Payment < ApplicationRecord
    belongs_to :account
    has_one :external_entity, as: :internal_entity
    monetize :amount_cents
    scope :from_customers, -> (range) { where(created_at: range).joins(:account).merge(Account.customer) }
    scope :from_organizations, -> (range) { where(created_at: range).joins(:account).merge(Account.organization) }

    # Gets all customer's payments from a specific time window (range) and calculates how much to pay out to each organization
    def self.calculate_organization_payouts(range)
        customer_payments_in_range = self.from_customers(range).includes(account: { owner: {payment_allocation_sets: { payment_allocations: { organization: :account}}}} )

        ungrouped_organization_payouts = customer_payments_in_range.flat_map do |p|
            customer_payment_allocations = p.account.owner.payment_allocations

            customer_payment_allocations.map do |a|
                amount = p.amount * a.percent / 100
                account = a.organization.account
                Payment.new(
                    amount: amount,
                    account: account
                )
            end
        end

        ungrouped_organization_payouts.group_by(&:account).map do |organziation, payments|
            payments.reduce do |sum, p|
                sum.amount += p.amount
                sum
            end
        end
    end
end
