class Customer < ApplicationRecord
  include Stripeable
  include PaysOut
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
  has_many :customer_tiers
  has_one_attached :avatar
  has_person_name

  validates :first_name, presence: true, length: { minimum: 2 }

  def first_name=(f_name)
    super f_name&.strip
  end

  def last_name=(l_name)
    super l_name&.strip
  end

  def current_tier
    tiers.active.first
  end
end
