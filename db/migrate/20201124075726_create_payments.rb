class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.references :owner, polymorphic: true, type: :uuid, index: { unique: true }
      t.timestamps
    end

    create_table :payments, id: :uuid do |t|
      t.monetize :amount
      t.references :account, type: :uuid
      t.timestamps
    end
  end
end
