module StripeHelper
  class Charge
    def self.customer(stripe_id, cents, currency)
      Stripe::Charge.create({
        amount: cents,
        currency: currency,
        customer: stripe_id
      })
    end
  end
end
