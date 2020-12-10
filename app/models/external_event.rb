class ExternalEvent < ApplicationRecord
  belongs_to :external_entity_source
  delegate :[], to: :raw
end
