class Tier < ApplicationRecord
  has_many :customer_tiers
  has_many :customers, through: :customer_tiers
end
