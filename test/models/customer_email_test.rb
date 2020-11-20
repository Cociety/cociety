require 'test_helper'

class CustomerEmailTest < ActiveSupport::TestCase
  setup do
    Current.customer = customers(:one)
    @email = customer_emails(:one)
  end

  test "refuses to save without a valid email" do
    assert_raise ActiveRecord::RecordInvalid do
      CustomerEmail.new(customer: Current.customer).save!
    end

    assert_raise ActiveRecord::RecordInvalid do
      CustomerEmail.new(customer: Current.customer, email: "").save!
    end

    assert_raise ActiveRecord::RecordInvalid do
      CustomerEmail.new(customer: Current.customer, email: "one").save!
    end

    assert_raise ActiveRecord::RecordInvalid do
      CustomerEmail.new(customer: Current.customer, email: "one@").save!
    end

    assert CustomerEmail.new(customer: Current.customer, email: "one@opensourcesociety.com").save!
  end

  test "refuses to save email for non current customer" do
    assert_raise ActiveRecord::RecordInvalid do
      CustomerEmail.new(customer: customers(:two), email: "test@opensourcesociety").save!
    end
  end
end
