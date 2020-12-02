class StripeHelper::Charge
  def self.customer(stripe_id, payment_method_id, cents, currency)
    Stripe::PaymentIntent.create({
                                   amount:         cents,
                                   currency:       currency,
                                   customer:       stripe_id,
                                   confirm:        true,
                                   payment_method: payment_method_id
                                 })
  end
end
