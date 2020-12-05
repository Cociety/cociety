require 'test_helper'

class PayoutTest < ActiveSupport::TestCase
  test 'splits payments between organizations' do
    charges = Charge.latest_succeeded_non_refunded
    expenses = Expense.sum
    payouts = Payout.from_charges charges, expenses
    assert_equal 2, payouts.size
    assert_equal Money.new(27, 'USD'), payouts.first.amount
    assert_equal organizations(:one).id, payouts.first.organization.id
    assert_equal Money.new(26_93, 'USD'), payouts.second.amount
    assert_equal organizations(:two).id, payouts.second.organization.id
  end

  test "has no payouts if profit isn't positive" do
    charges = [charges(:ten)]
    expenses = Expense.sum
    payouts = Payout.from_charges charges, expenses
    assert_empty payouts
  end
end
