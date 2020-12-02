# Handles events from Stripe
class StripeWebhooksController < ApiController
  before_action :set_event

  def create
    if type?
      render json: { message: StripeWebhookHelper.handle_event(@event) }
    else
      render json: { message: 'type parameter is required' }
    end
  end

  private

  def set_event
    @event = Stripe::Webhook.construct_event(
      payload, sig_header, StripeWebhookHelper.endpoint_secret
    )
  rescue Stripe::SignatureVerificationError => e
    Rails.logger.error e
    render body: nil, status: :unauthorized
  end

  def payload
    request.raw_post
  end

  def sig_header
    request.env['HTTP_STRIPE_SIGNATURE']
  end

  def type?
    @event.respond_to? :type
  end
end
