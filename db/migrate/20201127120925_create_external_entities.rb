class CreateExternalEntities < ActiveRecord::Migration[6.0]
  def change
    create_table :external_entity_sources, id: :uuid do |t|
      t.string :name, null: false
      t.string :description
      t.string :url
      t.index :name, unique: true
    end

    ExternalEntitySource.delete_all
    ExternalEntitySource.new(name: 'Stripe', description: 'payment processor', url: 'https://stripe.com/').save!

    create_table :external_entities, primary_key: %i[external_entity_source_id external_id] do |t|
      t.string :external_id, null: false, unique: true
      t.references :external_entity_source, type: :uuid, null: false
      t.references :internal_entity, polymorphic: true, type: :uuid, index: { name: 'index_type_id' }
      t.timestamps
      t.index %i[external_entity_source_id internal_entity_type internal_entity_id], name: 'index-entity_id-internal-type_internal-id'
    end
  end
end
