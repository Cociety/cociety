class RemovePwdDigest < ActiveRecord::Migration[6.1]
  def change
    remove_column :customers, :password_digest
  end
end
