class CreateChargesAndEvents < ActiveRecord::Migration[6.0]
  def change
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
      t.timestamps
      t.index :stripe_id, unique: false
      t.index :stripe_created, unique: false
    end
  end
end
