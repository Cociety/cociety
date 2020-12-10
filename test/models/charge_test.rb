require 'test_helper'

class ChargeTest < ActiveSupport::TestCase
  test 'has an event' do
    assert charges(:first).event
  end

  test 'gets latest event for a charge' do
    assert_equal charges(:last), charges(:first).latest_for_self
    assert_equal charges(:last), Charge.latest_for_stripe_id(charges(:first).stripe_id)
  end

  test 'gets latest events for all charges' do
    latest_charges = Charge.latest_succeeded_non_refunded
    assert_equal 168, latest_charges.size
    assert_equal charges(:last).id, latest_charges.first.id
  end

  test 'gets latest events in range' do
    to = charges(:charge_2500).stripe_created
    from = to - 500
    latest_charges = Charge.latest_succeeded_non_refunded(from..to)
    assert_equal 84, latest_charges.size
  end

  test 'filters out charges that were refunded' do
    to = charges(:charge_2500).stripe_created
    from = to - 500
    Charge.latest_succeeded_non_refunded(from..to).each do |c|
      assert_not c.refunded
    end
  end

  test 'filters out charges that haven\'t succeeded' do
    to = charges(:charge_2500).stripe_created
    from = to - 500
    Charge.latest_succeeded_non_refunded(from..to).each do |c|
      assert c.succeeded?
    end
  end
end
