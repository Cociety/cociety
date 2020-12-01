class ExternalEvent < ApplicationRecord
  belongs_to :external_entity_source
  delegate :[], to: :raw
  self.primary_keys = :external_entity_source_id, :external_event_id
end
