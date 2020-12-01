require 'test_helper'

class ChargeTest < ActiveSupport::TestCase
  test 'has a source' do
    assert charges(:first).source
  end

  test 'has an event' do
    assert charges(:first).event
  end

  test 'gets latest event for a charge' do
    assert_equal charges(:last).id, charges(:first).latest_for_self.id
  end

  test 'gets latest events for all charges' do
    latest_charges = Charge.latest
    assert_equal 1001, latest_charges.size
    assert_equal charges(:last).id, latest_charges.first.id
  end

  test 'gets latest events in range' do
    to = charges(:charge_2500).stripe_created
    from = to - 500
    latest_charges = Charge.latest(from..to)
    assert_equal 500, latest_charges.size
  end
end
