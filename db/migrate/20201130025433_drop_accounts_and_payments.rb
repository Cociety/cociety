class DropAccountsAndPayments < ActiveRecord::Migration[6.0]
  def change
    drop_table :accounts
    drop_table :payments
  end
end
