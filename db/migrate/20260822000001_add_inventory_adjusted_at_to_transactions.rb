class AddInventoryAdjustedAtToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :inventory_adjusted_at, :datetime
    add_column :purchases, :inventory_adjusted_at, :datetime
  end
end