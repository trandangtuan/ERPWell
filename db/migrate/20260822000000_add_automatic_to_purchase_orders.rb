class AddAutomaticToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :automatic, :boolean, default: false, null: false
    add_index :purchase_orders, [:store_id, :automatic, :status], name: 'index_purchase_orders_on_store_automatic_status'
  end
end