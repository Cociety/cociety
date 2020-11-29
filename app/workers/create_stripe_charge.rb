class CreateStripeCharge
  include Sidekiq::Worker
  sidekiq_options queue: 'stripe'

  def perform(payment_id)
    payment = Payment.find(payment_id)
    if payment.external_entity.present?
      Rails.logger.info "Payment already exists in Stripe: #{payment.external_entity.external_id}"
      return
    end
    stripe_charge = StripeHelper::Charge.create(payment)
    begin
      StripeHelper::Charge.link_to_payment(stripe_charge, payment)
    rescue => e
      Rails.logger.error(e)
      StripeHelper::Charge.cancel(stripe_charge.id)
    end
  end
end