class NullableCustomerIdForCharge < ActiveRecord::Migration[6.1]
  def change
    change_column :charges, :customer_id, :uuid, null: true
  end
end
