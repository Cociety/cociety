class CreateStripeCustomer
  include Sidekiq::Worker
  sidekiq_options queue: 'stripe'

  def perform(customer_id)
    customer = Customer.find(customer_id)

    existing_stripe_customer = StripeHelper::Customer.find_by_email(customer.email)
    if existing_stripe_customer
      begin
        StripeHelper::Customer.link_to_customer(existing_stripe_customer, customer)
      rescue ActiveRecord::RecordNotUnique => e
        logger.info 'Customer already has known Stripe id'
      end
    else
      new_stripe_customer = StripeHelper::Customer.create(customer)
      StripeHelper::Customer.link_to_customer(new_stripe_customer, customer)
    end
  end
end
