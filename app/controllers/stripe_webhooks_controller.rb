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

  def type?
    @event.respond_to? :type
  end

  def payload
    JSON.parse(request.raw_post, symbolize_names: true)
  end

  def set_event
    @event = Stripe::Event.construct_from(payload)
  end
end
