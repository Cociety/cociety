class CreateOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :organization_categories, id: :uuid do |t|
      t.string :category, null: false
      t.timestamps

      t.index :category, unique: true
    end

    ['Education', 'Environment', 'Health', 'Human Rights', 'Homelessness', 'Medical Research'].each do |i|
      OrganizationCategory.new(category: i).save
    end

    create_table :organizations, id: :uuid do |t|
      t.string :name
      t.string :description
      t.string :url
      t.timestamps
    end

    create_join_table :organizations, :organization_categories, column_options: { type: :uuid } do |t|
      t.index %i[organization_id organization_category_id], unique: true, name: 'organization_to_categories'
      t.index %i[organization_category_id organization_id], unique: true, name: 'category_to_organizations'
    end
  end
end
