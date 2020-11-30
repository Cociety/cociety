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
    email = CustomerEmail.new(email:"customersLastName@opensourcesociety.com")
    c = Customer.new(first_name: " has spaces ", last_name: " customersLastName ", password: "secret", emails: [email])
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

    customers(:one).payment_allocations.each do |p|
      assert_equal latest_payment_set_id, p.payment_allocation_set_id
    end
  end

  test "creates an account for new customers" do
    assert_no_changes -> { Account.count } do
      existing_customer = customers(:one)
      existing_customer.first_name = existing_customer.first_name + "test"
      existing_customer.save!
    end

    assert_changes -> { Account.count } do
      email = CustomerEmail.new(email:"mgalush@opensourcesociety.com")
      Customer.new(password: "test", first_name: "Melissa", last_name: "Galush", emails: [email]).save!
    end
  end

  test "refuses to create a customer without an email" do
    assert_raise ActiveRecord::RecordInvalid do
      Customer.new(password: "test", first_name: "Melissa", last_name: "Galush").save!
    end

    email = CustomerEmail.new(email:"mgalush@opensourcesociety.com")
    assert Customer.new(password: "test", first_name: "Melissa", last_name: "Galush", emails: [email]).save!
  end

  test "finds a customer by stripe id" do
    assert Customer.find_by_stripe_id(123)
  end

  test "charges a customer's payment method" do
    assert_changes -> { CreateStripeCharge.jobs.size } do
      customers(:one).create_charge(Money.new(100, "USD"))
    end
  end
end
