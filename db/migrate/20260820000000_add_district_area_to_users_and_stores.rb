class AddDistrictAreaToUsersAndStores < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :district_area, :string
    add_column :stores, :district_area, :string
  end
end
