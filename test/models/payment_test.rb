require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test "requires an amount" do
    p = Payment.new
    p.amount = nil
    assert_raise ActiveRecord::RecordInvalid do
      p.save!
    end
  end
end
