require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  test 'finds a customer by email' do
    expected_customer_id = customers(:one).id
    actual_customer_id = Customer.find_by_email('customer_one@cociety.org').id
    assert_equal expected_customer_id, actual_customer_id
  end

  test "strips whitespace from customer's name before saving" do
    c = Customer.new(first_name: ' has spaces ', last_name: ' customersLastName ', password: 'secret', email: 'customersLastName@cociety.org')
    c.save!
    assert_equal 'has spaces', c.first_name
    assert_equal 'customersLastName', c.last_name
  end

  test "properly formats customer's full name" do
    c = Customer.new(first_name: ' has spaces ', last_name: ' customersLastName ')
    assert_equal 'has spaces customersLastName', c.name
  end

  test 'gets the latest payment allocations' do
    latest_payment_set_id = customers(:one).payment_allocation_sets.last.id

    customers(:one).payment_allocations.each do |p|
      assert_equal latest_payment_set_id, p.payment_allocation_set_id
    end
  end

  test 'refuses to create a customer without an email' do
    assert_raise ActiveRecord::RecordInvalid do
      Customer.new(password: 'test123', first_name: 'Melissa', last_name: 'Galush').save!
    end

    assert Customer.new(password: 'test123', first_name: 'Melissa', last_name: 'Galush', email: 'mgalush@cociety.org').save!
  end

  test 'finds a customer by stripe id' do
    assert Customer.find_by_stripe_id external_entities(:one).external_id
  end

  test "charges a customer's payment method" do
    assert_changes -> { CreateStripeCharge.jobs.size } do
      customers(:one).create_charge(100, 'USD')
    end
  end

  test "gets a customer's current tier" do
    assert_equal customer_tiers(:one_current).id, customers(:one).current_tier.id
  end

  test 'splits payment allocations evenly between all organizations on sign up' do
    c = Customer.new(password: 'test123', first_name: 'Melissa', last_name: 'Galush', email: 'something_new@cociety.org')
    c.save
    assert c.payment_allocations.size == Organization.count
    percents = c.payment_allocations.map(&:percent)
    assert (percents.max - percents.min).between?(0, 1)
  end
end
