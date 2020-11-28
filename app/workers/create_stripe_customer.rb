class CreateStripeCustomer
  include Sidekiq::Worker
  sidekiq_options queue: 'stripe'

  def perform(customer_id)
    customer = Customer.find(customer_id)

    existing_customer = StripeHelper::Customer.find_by_email(customer.default_email.email)
    if existing_customer
      begin
        StripeHelper::Customer.link_to_customer(existing_customer, customer)
      rescue ActiveRecord::RecordNotUnique => exception
        Rails.logger.info "Customer already has known Stripe id"
      end
    else
      new_customer = StripeHelper::Customer.create(customer)
      StripeHelper::Customer.link_to_customer(new_customer, customer)
    end
  end
end