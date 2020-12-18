# rails g migration AddLogoToOrganizations logo:string
class AddLogoToOrganizations < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :logo, :string
  end
end
