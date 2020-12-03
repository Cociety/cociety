require 'test_helper'

class PayoutTest < ActiveSupport::TestCase
  test 'splits payments between organizations' do
    charges = Charge.latest_succeeded_non_refunded
    payouts = Payout.from_charges charges
    assert_equal 2, payouts.size
    assert_equal Money.new(168, 'USD'), payouts[organizations(:one).id].amount
    assert_equal Money.new(16_632, 'USD'), payouts[organizations(:two).id].amount
    payouts.each do |organization_id, payout|
      assert_equal organization_id, payout.organization.id
    end
  end
end
