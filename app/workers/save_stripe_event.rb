# handles events from the public stripe webhook
class SaveStripeEvent
  include Sidekiq::Worker
  sidekiq_options queue: 'stripe'

  def perform(payload, signature)
    event = Stripe::Webhook.construct_event(payload, signature, StripeHelper::Webhook.endpoint_secret)
    logger.info "Processing stripe event #{event.id}"
    external_event = ExternalEvent.new(
      external_id:            event.id,
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
      logger.error e
      logger.info "Setup #{klass_name} class to handle #{external_event['type']} events"
    end
  end

  def create_class_name_from_event_type(event_type)
    suffix = event_type.split('.').map(&:classify).join('::')
    "EventHandler::#{suffix}"
  end
end
