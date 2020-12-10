class EventHandler::Charge::Abstract < EventHandler::Abstract
  attr_reader :stripe_charge

  def initialize(external_event:)
    super(external_event: external_event)
    @stripe_charge = @external_event['data']['object']
  end

  def handle(_external_event)
    initialize_charge_model.save!
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.error e
    Rails.logger.error "Duplicate charge event detected for event #{stripe_event_id} and charge #{stripe_charge_id}"
    throw e
  end

  def customer
    Customer.find_by_stripe_id stripe_customer_id
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error e
    Rails.logger.error "Failed to find customer for stripe id #{stripe_customer_id}"
  end

  def stripe_customer_id
    @stripe_charge['customer']
  end

  def stripe_charge_id
    @stripe_charge['id']
  end

  def initialize_charge_model
    Charge.new(
      amount:         Money.new(@stripe_charge['amount'], @stripe_charge['currency']),
      customer:       customer,
      refunded:       @stripe_charge['refunded'],
      status:         @stripe_charge['status'],
      stripe_created: @stripe_charge['created'],
      stripe_id:      stripe_charge_id,
      external_event: @external_event
    )
  end
end
