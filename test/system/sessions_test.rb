require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "redirects after login" do
    visit new_customer_session_path(params: { redirect_to: customer_profile_index_url })

    fill_in :customer_email, with: customers(:one).email
    fill_in :customer_password, with: :password

    click_button :Login

    assert_equal customer_profile_index_url, current_url
  end

  test "redirects param persists after navigating around" do
    visit new_customer_session_path(params: { redirect_to: customer_profile_index_url })
    visit root_path
    visit new_customer_session_path

    fill_in :customer_email, with: customers(:one).email
    fill_in :customer_password, with: :password

    click_button :Login

    assert_equal customer_profile_index_url, current_url
  end
end
