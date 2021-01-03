class Customer < ApplicationRecord
  include Stripeable
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable,
         timeout_in: 2.weeks

  alias_attribute :tiers, :customer_tiers
  default_scope { order(created_at: :asc) }
  has_many :charges
  has_many :external_entities, as: :internal_entity
  has_many :payment_allocation_sets, autosave: true
  has_many :customer_tiers
  has_one_attached :avatar
  has_person_name

  def first_name=(f_name)
    super f_name&.strip
  end

  def last_name=(l_name)
    super l_name&.strip
  end

  def payment_allocations
    payment_allocation_sets&.first&.payment_allocations || []
  end

  def payment_allocations_for_all_organizations
    p = payment_allocations
    o_donated_to = p.map(&:organization_id)
    o_not_donated_to = Organization.where.not(id: o_donated_to)
    o_not_donated_to.each do |o|
      p.push PaymentAllocation.new(percent: 0, organization: o)
    end
    p
  end

  def current_tier
    tiers.active.first
  end
end
