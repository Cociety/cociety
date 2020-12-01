class CreateStripeCharge
  include Sidekiq::Worker
  sidekiq_options queue: 'stripe'

  def perform(stripe_id, cents, currency)
    payment_method_id = StripeHelper::Customer.default_payment_id(stripe_id)
    begin
      StripeHelper::Charge.customer(stripe_id, payment_method_id, cents, currency)
    rescue Stripe::CardError, Stripe::InvalidRequestError => e
      logger.error(e.message)
      # TODO: notify customer that their charge failed
    end
  end
end
