require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  test "finds a customer by email" do
    expectedCustomerId = customers(:one).id
    actualCustomerId = Customer.find_by_email("customer_one_2@opensourcesociety.com").id
    assert_equal expectedCustomerId, actualCustomerId
  end

  test "returns a customers default email" do
    customer = Customer.find_by_email("customer_one_2@opensourcesociety.com")
    assert_equal "customer_one@opensourcesociety.com", customer.default_email.email
    assert customer.default_email.is_default
  end

  test "strips whitespace from customer's name before saving" do
    c = Customer.new(first_name: " has spaces ", last_name: " customersLastName ", password: "secret")
    c.save!
    assert_equal "has spaces", c.first_name
    assert_equal "customersLastName", c.last_name
  end

  test "properly formats customer's full name" do
    c = Customer.new(first_name: " has spaces ", last_name: " customersLastName ")
    assert_equal "has spaces customersLastName", c.full_name
  end

  test "gets the latest payment allocations" do
    latest_payment_set_id = customers(:one).payment_allocation_sets.last.id

    customers(:one).payment_allocations.each {|p|
      assert_equal latest_payment_set_id, p.payment_allocation_set_id
    }
  end

  test "creates an account for new customers" do
    assert_no_changes -> { Account.count } do
      existing_customer = customers(:one)
      existing_customer.first_name = existing_customer.first_name + "test"
      existing_customer.save!
    end

    assert_changes -> { Account.count } do
      Customer.new(password: "test", first_name: "Melissa", last_name: "Galush").save!
    end
  end
end
