module Customer::Stripeable
  extend ActiveSupport::Concern
  included do
    after_create :create_stripe_customer
    def self.find_by_stripe_id(stripe_id)
      ExternalEntity.includes(:internal_entity)
                    .find([ExternalEntitySource.Stripe.id, stripe_id])
                    .internal_entity
    rescue ActiveRecord::RecordNo´tFound => e
      Rails.logger.error(e, "Failed to find customer for stripe id #{stripe_id}")
    end
  end

  def stripe_id
    external_entities.by_name('Stripe').first&.external_id
  end

  def create_charge(cents, currency)
    CreateStripeCharge.perform_async(stripe_id, cents, currency)
  end

  def add_payment_card(card_args)
    StripeHelper::PaymentMethod.create_card(stripe_id, card_args)
  end

  def payment_cards
    StripeHelper::PaymentMethod.get_cards(stripe_id)
  end

  def create_stripe_customer
    CreateStripeCustomer.perform_async(id)
  end
end
