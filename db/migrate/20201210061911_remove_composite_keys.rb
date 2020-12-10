class RemoveCompositeKeys < ActiveRecord::Migration[6.0]
  def up
    drop_table :charges
    drop_table :external_events
    drop_table :external_entities

    create_table :external_entities, id: :uuid do |t|
      t.string :external_id, null: false, unique: true
      t.references :external_entity_source, type: :uuid, null: false
      t.references :internal_entity, polymorphic: true, type: :uuid, index: { name: 'index_type_id' }
      t.timestamps
      t.index %i[external_entity_source_id internal_entity_type internal_entity_id], name: 'index-entity_id-internal-type_internal-id'
    end

    create_table :external_events, id: :uuid do |t|
      t.string :external_id, null: false
      t.references :external_entity_source, type: :uuid, null: false
      t.json :raw
      t.timestamps
      t.index %i[external_entity_source_id external_id], unique: false, name: 'index-external_source-external_id'
    end

    create_table :charges, id: :uuid do |t|
      t.monetize :amount, null: false
      t.boolean :refunded, default: false
      t.integer :status, null: false
      t.integer :stripe_created
      t.string :stripe_id
      t.references :external_event, type: :uuid, null: false
      t.references :customer, foreign_key: true, type: :uuid, null: false
      t.timestamps
      t.index :stripe_id, unique: false
      t.index :stripe_created, unique: false
    end
  end

  def down
    drop_table :charges
    drop_table :external_events
    drop_table :external_entities

    create_table :external_entities, primary_key: %i[external_entity_source_id external_id] do |t|
      t.string :external_id, null: false, unique: true
      t.references :external_entity_source, type: :uuid, null: false
      t.references :internal_entity, polymorphic: true, type: :uuid, index: { name: 'index_type_id' }
      t.timestamps
      t.index %i[external_entity_source_id internal_entity_type internal_entity_id], name: 'index-entity_id-internal-type_internal-id'
    end

    create_table :external_events, primary_key: %i[external_entity_source_id external_event_id] do |t|
      t.string :external_event_id, null: false
      t.references :external_entity_source, type: :uuid, null: false
      t.json :raw
      t.timestamps
      t.index %i[external_entity_source_id external_event_id], unique: false, name: 'index-external_source-external_id'
    end

    create_table :charges, primary_key: %i[external_entity_source_id external_event_id stripe_id] do |t|
      t.monetize :amount, null: false
      t.boolean :refunded, default: false
      t.integer :status, null: false
      t.integer :stripe_created
      t.string :stripe_id
      t.references :external_event, type: :string, null: false
      t.references :external_entity_source, type: :uuid, null: false
      t.references :customer, foreign_key: true, type: :uuid, null: false
      t.timestamps
      t.index :stripe_id, unique: false
      t.index :stripe_created, unique: false
    end

  end
end
