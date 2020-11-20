require 'test_helper'

class PaymentAllocationTest < ActiveSupport::TestCase
  test "only saves percents > 0 and <= 100" do
    p = payment_allocations(:one)
    p.percent = 0
    assert_raise ActiveRecord::RecordInvalid do
      p.save!
    end

    p.percent = 101
    assert_raise ActiveRecord::RecordInvalid do
      p.save!
    end

    p.percent = 100
    assert p.save!

    p.percent = 1
    assert p.save!
  end
end
