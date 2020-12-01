class ExternalEntitySource < ApplicationRecord
  has_many :external_entities

  def self.Stripe
    ExternalEntitySource.find_by_name('Stripe')
  end
end
