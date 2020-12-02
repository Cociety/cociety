require 'test_helper'

class PayoutHelperTest < ActiveSupport::TestCase
  include PayoutHelper

  test 'splits payments between organizations' do
    charges = Charge.latest_succeeded_non_refunded
    payouts = calculate_organization_payouts_from_charges charges
    assert_equal 2, payouts.size
    assert_equal Money.new(168, 'USD'), payouts[organizations(:one).id]
    assert_equal Money.new(16_632, 'USD'), payouts[organizations(:two).id]
  end
end
