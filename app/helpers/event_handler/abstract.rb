class EventHandler::Abstract
  attr_reader :external_event

  def initialize(external_event:)
    @external_event = external_event
  end

  def handle(_external_event)
    raise 'handle method must be implemented'
  end

  def stripe_event_id
    @external_event.external_event_id
  end
end
