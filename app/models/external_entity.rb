class ExternalEntity < ApplicationRecord
  alias_attribute :source, :external_entity_source
  belongs_to :internal_entity, polymorphic: true
  belongs_to :external_entity_source
  self.primary_keys = :external_entity_source_id, :external_id
  scope :by_name, -> (name) { joins(:external_entity_source).where(external_entity_sources: {name: name}) }
end
