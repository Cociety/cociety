class Customer < ApplicationRecord
  before_save { first_name&.strip! }
  before_save { last_name&.strip! }
  has_secure_password
  has_many :emails, class_name: "CustomerEmail", autosave: true
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false

  def self.find_by_email(email)
    CustomerEmail.includes(:customer)
                 .find_by_email(email)
                 &.customer
  end

  def default_email
    self.emails.find_by_is_default(true)
  end

  def full_name
   "#{self.first_name.strip()} #{self.last_name.strip()}".strip()
  end
end
