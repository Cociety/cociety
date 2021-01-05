require 'test_helper'

class Customer::SessionControllerTest < ActionDispatch::IntegrationTest
  test 'redirects to given url after login' do
    sign_in customers(:one)
    get new_customer_session_path(redirect_to: 'http://test.example.com')
    assert_redirected_to 'http://test.example.com'
  end

  test 'refuses to redirect to url outside of the domain' do
    sign_in customers(:one)
    get new_customer_session_path(redirect_to: 'http://test.example.org')
    assert_redirected_to 'http://www.example.com/'
  end

  test 'sets hidden redirect_to form input' do
    sign_out :customer
    get new_customer_session_path(redirect_to: 'http://test.example.com')
    assert_select "form[action='#{new_customer_session_path}']" do
      assert_select 'input[name="redirect_to"][type=hidden][value="http://test.example.com"]', count: 1
    end
  end

  test 'refuses to set hidden redirect_to form input to url outside of the domain' do
    sign_out :customer
    get new_customer_session_path(redirect_to: 'http://test.example.org')
    assert_select "form[action='#{new_customer_session_path}']" do
      assert_select 'input[name="redirect_to"][type=hidden][value="http://test.example.org"]', count: 0
    end
  end

  test 'does not set hidden redirect_to form input if not provided' do
    sign_out :customer
    get new_customer_session_path
    assert_select "form[action='#{new_customer_session_path}']" do
      assert_select 'input[name="redirect_to"][type=hidden][value="http://test.example.com"]', count: 0
    end
  end
end
