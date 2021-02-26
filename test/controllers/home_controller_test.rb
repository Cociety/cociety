require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in customers(:one)
  end

  test 'should get home page' do
    get root_path
    assert_response :success
    assert_select 'title', 'Cociety [test]'
  end

  test 'should show the nav bar with signup and login buttons when logged out' do
    sign_out :customer
    get root_path
    assert_select 'nav' do
      assert_select 'a.btn', 4 # two for mobile and 2 for desktop
      assert_select 'a.btn.btn-primary', { count: 2, text: 'Sign up' }
      assert_select 'a.btn.btn-secondary', { count: 2, text: 'Login' }
    end
  end

  test 'should not show login and signup buttons when logged in' do
    get root_path
    assert_select 'nav' do
      assert_select 'a.btn.btn-primary', { count: 0, text: 'Sign up' }
      assert_select 'a.btn.btn-secondary', { count: 0, text: 'Login' }
    end
  end

  test 'should show avatar when logged in' do
    get root_path
    assert_select 'nav' do
      assert_select 'img[alt="Customer One"]', { count: 2 }
    end
  end
end
