class Customer < ApplicationRecord
  include Accountable

  after_create :create_stripe_customer
  before_save { first_name&.strip! }
  before_save { last_name&.strip! }
  has_secure_password
  has_many :emails, class_name: "CustomerEmail", autosave: true
  has_many :external_entities, as: :internal_entity
  has_many :payment_allocation_sets, autosave: true
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false
  validates :emails, length: { minimum: 1 }

  def self.find_by_email(email)
    CustomerEmail.includes(:customer)
                 .find_by_email(email)
                 &.customer
  end

  def create_stripe_customer
    CreateStripeCustomer.perform_async(id)
  end

  def default_email
    self.emails.find_by_is_default(true)
  end

  def full_name
   "#{self.first_name.strip()} #{self.last_name.strip()}".strip()
  end

  def payment_allocations
    payment_allocation_sets.last.payment_allocations
  end
end
