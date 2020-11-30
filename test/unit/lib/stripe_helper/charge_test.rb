require 'test_helper'

class ChargeTest < ActiveSupport::TestCase
  
  test "creates a Stripe charge" do
    assert StripeHelper::Charge.customer(123, 100, "USD")
  end

  test "throws card erros" do
    StripeMock.prepare_card_error(:card_declined)
    assert_raise Stripe::CardError do
      StripeHelper::Charge.customer(123, 100, "USD")
    end
  end
end
