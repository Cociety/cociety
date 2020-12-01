class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers, id: :uuid do |t|
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.timestamps
    end

    create_table :customer_emails, id: :uuid do |t|
      t.string :email
      t.references :customer, null: false, foreign_key: true, type: :uuid
      t.boolean :is_verified, null: false, default: false
      t.boolean :is_default, null: false, default: false

      t.timestamps
    end
    add_index :customer_emails, :email, unique: true
    add_index :customer_emails, %i[customer_id is_default], unique: true, where: 'is_default'
  end
end
