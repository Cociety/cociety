class OrganizationCategory < ApplicationRecord
  has_and_belongs_to_many :organizations
  validates :category, length: { minimum: 3 }
end
