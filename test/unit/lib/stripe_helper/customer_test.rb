require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  def setup
    @customer = customers(:one)
  end

  test 'creates a Stripe customer' do
    stripe_customer = StripeHelper::Customer.create(@customer)
    assert_equal 'Customer One', stripe_customer.name
    assert_equal 'customer_one@cociety.org', stripe_customer.email
    assert_equal @customer.id, stripe_customer.metadata['customer_id']
  end

  test 'links stripe customer to local customer' do
    assert_changes -> { ExternalEntity.count } do
      stripe_customer = StripeHelper::Customer.create(@customer)
      assert StripeHelper::Customer.link_to_customer(stripe_customer, @customer)
      assert_equal @customer.external_entities.order(created_at: :desc).first.external_id, stripe_customer.id
    end
  end
end
