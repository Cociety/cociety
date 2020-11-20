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
end
