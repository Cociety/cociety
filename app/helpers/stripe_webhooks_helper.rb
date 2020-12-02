# Helper for StripeWebhooksController
module StripeWebhooksHelper
  def endpoint_secret
    Rails.application.credentials.stripe[:signing_secret]
  end

  def handle_event(event)
    external_event = ExternalEvent.new(
      external_event_id:      event.id,
      external_entity_source: ExternalEntitySource.Stripe,
      raw:                    event
    )
    external_event.save!
    handle_event_type external_event
  end

  def handle_event_type(external_event)
    klass_name = create_class_name_from_event_type external_event['type']
    begin
      klass_name.constantize
                .new(external_event: external_event)
                .handle(external_event)
    rescue NameError => e
      Rails.logger.error e
      message = "Setup #{klass_name} class to handle #{external_event['type']} events"
      Rails.logger.info message
      message
    end
  end

  def create_class_name_from_event_type(event_type)
    suffix = event_type.split('.').map(&:classify).join('::')
    "EventHandler::#{suffix}"
  end
end
