require 'test_helper'

class Customer::ProfileControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    sign_in @customer
  end

  test 'should get customer profile page' do
    get customer_profile_index_path
    assert_response :success
  end

  test 'should redirect customer profile page if logged out' do
    sign_out :customer
    get customer_profile_index_path
    assert_redirected_to new_customer_session_path
  end

  test 'should show basic customer details' do
    get customer_profile_index_path
    assert_select 'h2', { count: 1, text: 'Basic details' }
    assert_select "input[value='#{@customer.first_name}']"
    assert_select "input[value='#{@customer.last_name}']"
    assert_select "input[value='#{@customer.email}']"
  end

  test 'should show donation information' do
    get customer_profile_index_path
    assert_select 'h2', { count: 1, text: 'Where are my donations going?' }

    assert_select 'p', { count: 1, text: 'Health Planet' }
    assert_select 'a', { count: 1, text: 'https://www.healthplanet.abc' }
    assert_select 'p', { count: 1, text: 'worldwide fitness' }

    assert_select 'p', { count: 1, text: "A's for Days" }
    assert_select 'a', { count: 1, text: 'https://as4days.abc' }
    assert_select 'p', { count: 1, text: 'tutoring for kiddos' }
  end

  test 'should have a save donations form' do
    get customer_profile_index_path
    assert_select "form[action*='#{customer_payment_allocations_path}']" do
      assert_select 'input[type=submit][value=Save]'
    end
  end
end
