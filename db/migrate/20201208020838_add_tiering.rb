class AddTiering < ActiveRecord::Migration[6.0]
  def change
    create_table :tiers, id: :uuid do |t|
      t.string :name, null: false, unique: true
      t.timestamps
    end

    create_table :customer_tiers, id: :uuid do |t|
      t.references :customer, null: false, foreign_key: true, type: :uuid
      t.references :tier, null: false, foreign_key: true, type: :uuid
      t.datetime :effective, null: false
      t.datetime :expiration, null: false
      t.timestamps
    end

    Tier.new(name: 'free').save!
    Tier.new(name: 'paid').save!
    Tier.new(name: 'paid+').save!
  end
end
