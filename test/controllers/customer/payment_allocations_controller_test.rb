require 'test_helper'

class Customer::PaymentAllocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    sign_in @customer
  end

  test 'should create payment allocations' do
    assert_difference -> { PaymentAllocationSet.count } do
      post customer_payment_allocations_url, params: { payment_allocations: [percent: 100, organization_id: organizations(:one).id ]}
    end
    assert_redirected_to customer_profile_index_path
    assert_equal 'Donations updated. Thanks for the help!', flash[:notice]
  end

  test 'should fail if percents dont sum to 100' do
    assert_no_difference -> { PaymentAllocationSet.count } do
      post customer_payment_allocations_url, params: { payment_allocations: [percent: 99, organization_id: organizations(:one).id ]}
    end
    assert_redirected_to customer_profile_index_path
    assert_equal ['Percentages must add to 100'], flash[:alert]
  end
end
