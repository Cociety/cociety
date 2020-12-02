class AddCustomerRefToCharges < ActiveRecord::Migration[6.0]
  def up
    add_reference :charges, :customer, foreign_key: true, type: :uuid
    customer = Customer.first
    Charge.all.each do |c|
      c.customer = customer
      c.save!
    end
    change_column :charges, :customer_id, :uuid, null: false
  end

  def down
    remove_reference :charges, :customer
  end
end
