class CustomerEmail < ApplicationRecord
  default_scope -> { order(:created_at => :asc) }
  belongs_to :customer
  before_save { email&.strip! }
  before_save :set_is_default
  before_destroy :check_if_default, prepend: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :belongs_to_current_customer

  def find_by_email(email)
    super(email.strip)
  end

  private

  def belongs_to_current_customer
    errors[:base] << "does not belong to authenticated customer" if customer&.id != Current&.customer&.id
  end

  def check_if_default
    if self.is_default
      errors[:base] << "can't delete default email"
      throw :abort
    end
  end

  def set_is_default
    self.is_default = !CustomerEmail.exists?(customer_id: customer_id, is_default: true)
  end
end
