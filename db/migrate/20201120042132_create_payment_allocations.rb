class CreatePaymentAllocations < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_allocation_sets, id: :uuid do |t|
      t.references :customer, null: false, type: :uuid
      t.timestamps
    end

    create_table :payment_allocations, id: :uuid do |t|
      t.references :payment_allocation_set, null: false, index: { name: 'index_payment_to_group' }, type: :uuid
      t.references :organization, null: false, type: :uuid
      t.integer :percent
    end
  end
end
