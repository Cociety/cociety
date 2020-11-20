require 'test_helper'

class PaymentAllocationSetTest < ActiveSupport::TestCase
  test "must have at least one payment allocation" do
    assert_raise ActiveRecord::RecordInvalid do
      PaymentAllocationSet.new(customer: customers(:one)).save!
    end

    assert_raise ActiveRecord::RecordInvalid do
      PaymentAllocationSet.new(payment_allocations: [], customer: customers(:one)).save!
    end

    assert PaymentAllocationSet.new(payment_allocations: payment_allocations(:one, :ninety_nine), customer: customers(:one)).save!
  end

  test "payment percents must total to 100" do
    assert_raise ActiveRecord::RecordInvalid do
      PaymentAllocationSet.new(
        customer: customers(:one),
        payment_allocations: [payment_allocations(:fifty)]
      ).save!
    end

    assert_raise ActiveRecord::RecordInvalid do
      PaymentAllocationSet.new(
        customer: customers(:one),
        payment_allocations: payment_allocations(:fifty, :one)
      ).save!
    end

    assert PaymentAllocationSet.new(
      customer: customers(:one),
      payment_allocations: payment_allocations(:fifty, :fifty)
    ).save!
  end

  test "each allocation must be valid before saving the set" do
    assert_raise ActiveRecord::RecordInvalid do
      PaymentAllocationSet.new(
        customer: customers(:one),
        payment_allocations: payment_allocations(:neg_fifty, :fifty, :fifty, :fifty)
      ).save!
    end
  end
end
