require 'test_helper'

class CustomerEmailTest < ActiveSupport::TestCase
  setup do
    @customer = customers(:one)
    @email = customer_emails(:one)
  end

  test 'refuses to save without a valid email' do
    assert_raise ActiveRecord::RecordInvalid do
      CustomerEmail.new(customer: @customer).save!
    end

    assert_raise ActiveRecord::RecordInvalid do
      CustomerEmail.new(customer: @customer, email: '').save!
    end

    assert_raise ActiveRecord::RecordInvalid do
      CustomerEmail.new(customer: @customer, email: 'one').save!
    end

    assert_raise ActiveRecord::RecordInvalid do
      CustomerEmail.new(customer: @customer, email: 'one@').save!
    end

    assert CustomerEmail.new(customer: @customer, email: 'one@opensourcesociety.com').save!
  end
end
