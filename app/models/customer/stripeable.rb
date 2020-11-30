module Customer::Stripeable
  extend ActiveSupport::Concern
  included do
    after_create :create_stripe_customer
    def self.find_by_stripe_id(stripe_id)
      begin
        ExternalEntity.includes(:internal_entity)
                      .find([ExternalEntitySource.find_by_name("Stripe").id, stripe_id])
                      .internal_entity
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("Failed to find customer for stripe id #{stripe_id}")
      end
    end
  end

  def stripe_id
    external_entities.by_name("Stripe").first&.external_id
  end

  def create_charge(amount)
    CreateStripeCharge.perform_async(stripe_id, amount.fractional, amount.currency)
  end

  def create_stripe_customer
    CreateStripeCustomer.perform_async(id)
  end
end