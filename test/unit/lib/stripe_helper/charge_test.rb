require 'test_helper'

class ChargeTest < ActiveSupport::TestCase
  
  test "creates a Stripe charge" do
    assert StripeHelper::Charge.customer(123, 123, 100, "USD")
  end
end
