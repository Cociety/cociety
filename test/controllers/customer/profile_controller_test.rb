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

  test 'should show a customer profile' do
    get customer_profile_index_path
    assert_select 'h2', { count: 1, text: 'Basic details' }
    assert_select "#{profile_form} input[value='#{@customer.first_name}']"
    assert_select "#{profile_form} input[value='#{@customer.last_name}']"
    assert_select "#{profile_form} input[value='#{@customer.email}']"
  end

  test 'should have an avatar uploader' do
    get customer_profile_index_path
    assert_select 'label[for="customer\[avatar\]"]', { count: 1, text: 'Choose Photo' }
    assert_select 'input[name="customer\[avatar\]"]'
  end

  test 'should have a save profile button' do
    get customer_profile_index_path
    assert_select "#{profile_form} button[type=submit]", { count: 1, text: 'Save' }
  end

  test 'should show donation information' do
    get customer_profile_index_path
    assert_select 'h2', { count: 1, text: 'Where are my donations going?' }

    assert_select 'label', { count: 1, text: 'Percent to Health Planet' }
    assert_select 'a[href="https://www.healthplanet.abc"]'
    assert_select 'p', { count: 1, text: 'worldwide fitness' }

    assert_select 'label', { count: 1, text: "Percent to A's for Days" }
    assert_select 'a[href="https://as4days.abc"]'
    assert_select 'p', { count: 1, text: 'tutoring for kiddos' }
  end

  test 'should have a save donations form' do
    get customer_profile_index_path
    assert_select "form[action*='#{customer_payment_allocations_path}']" do
      assert_select 'button[type=submit]', { count: 1, text: 'Save' }
    end
  end

  test 'should save customer profile' do
    assert_not_equal 'new first name', customers(:one).first_name
    put customer_profile_url(@customer), params: { customer: { first_name: 'new first name' } }
    assert_equal 'new first name', customers(:one).first_name
    assert_equal 'Profile Updated!', flash[:notice]
  end

  test 'should show a different message when updating email' do
    put customer_profile_url(@customer), params: { customer: { email: 'new_email_for_customer_one@cociety.org' } }
    assert_equal 'new_email_for_customer_one@cociety.org', customers(:one).unconfirmed_email
    assert_equal 'Profile Updated! Check your email to confirm your new address.', flash[:notice]
  end

  test 'should update customer avatar' do
    image = fixture_file_upload 'images/arya.jpg'
    assert_changes -> { ActiveStorage::Attachment.count } do
      put customer_profile_url(@customer), params: { customer: { avatar: image } }
      assert_response :redirect
    end
  end

  private

  def profile_form
    "form[action*='#{customer_profile_url(@customer)}']"
  end
end
