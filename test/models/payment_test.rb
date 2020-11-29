require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test "requires an amount" do
    p = Payment.new
    p.amount = nil
    assert_raise ActiveRecord::RecordInvalid do
      p.save!
    end
  end

  test "calculates organization payouts" do
    expected = [
      Payment.new(amount: 10.15, account: accounts(:three)),
      Payment.new(amount: 24.85, account: accounts(:four))
    ]
    actual = Payment.calculate_organization_payouts(Float::INFINITY..Float::INFINITY)
    assert_equal expected.inspect, actual.inspect
  end

  test "queues a stripe charge to be created on create" do
    assert_changes -> { CreateStripeCharge.jobs.size } do
      Payment.new(
        amount: 10,
        account: accounts(:one)
      ).save!
    end
  end
end
