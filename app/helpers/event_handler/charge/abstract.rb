class EventHandler::Charge::Abstract < EventHandler::Abstract
  attr_reader :stripe_charge

  def initialize(external_event:)
    super(external_event: external_event)
    @stripe_charge = @external_event['data']['object']
  end

  def handle(_external_event)
    initialize_charge_model.save!
  end

  def customer
    Customer.find_by_stripe_id @stripe_charge['customer']
  end

  def initialize_charge_model
    Charge.new(
      amount:                    Money.new(@stripe_charge['amount'], @stripe_charge['currency']),
      customer:                  customer,
      refunded:                  @stripe_charge['refunded'],
      status:                    @stripe_charge['status'],
      stripe_created:            @stripe_charge['created'],
      stripe_id:                 @stripe_charge['id'],
      external_entity_source_id: @external_event.external_entity_source_id,
      external_event_id:         @external_event.external_event_id
    )
  end
end
