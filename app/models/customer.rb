class Customer < ApplicationRecord
  include Stripeable
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  alias_attribute :tiers, :customer_tiers
  before_save { first_name&.strip! }
  before_save { last_name&.strip! }
  default_scope { order(created_at: :asc) }
  has_many :charges
  has_many :external_entities, as: :internal_entity
  has_many :payment_allocation_sets, autosave: true
  has_many :customer_tiers
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false

  def full_name
    "#{first_name.strip} #{last_name.strip}".strip
  end

  def payment_allocations
    payment_allocation_sets.last.payment_allocations
  end

  def current_tier
    tiers.active.first
  end
end
