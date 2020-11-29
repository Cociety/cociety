module StripeHelper
  class Charge
    def self.create(payment)
      customer = payment.account.owner
      stripe_customer = customer.external_entities.by_name("Stripe").first

      if not stripe_customer
        customer.create_stripe_customer
        raise new ActiveRecord::RecordNotFound("Couldn't find Stripe customer for Customer #{customer.id}")
      end

      Stripe::PaymentIntent.create({
        amount: payment.amount.fractional,
        currency: payment.amount.currency,
        customer: stripe_customer.external_id,
        metadata: {
          payment_id: payment.id
        }
      })
    end

    def self.link_to_payment(stripe_charge, payment)
      payment.build_external_entity(
        external_id: stripe_charge.id,
        source: ExternalEntitySource.find_by_name("Stripe")
      ).save!
    end

    def self.cancel(external_id)
      Stripe::PaymentIntent.cancel(external_id)
    end
  end
end
