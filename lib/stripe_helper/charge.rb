module StripeHelper
  class Charge
    def self.customer(stripe_id, amount)
      Stripe::Charge.create({
        amount: amount.fractional,
        currency: amount.currency,
        customer: stripe_id
      })
    end
  end
end
