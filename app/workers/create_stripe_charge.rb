class CreateStripeCharge
  include Sidekiq::Worker
  sidekiq_options queue: 'stripe'

  def perform(stripe_id, cents, currency)
    amount = Money.new(cents, currency)
    begin
      StripeHelper::Charge.customer(stripe_id, amount)
    rescue Stripe::CardError, Stripe::InvalidRequestError => e
      logger.error(e.message)
      # TODO notify customer that their charge failed
    end
  end
end