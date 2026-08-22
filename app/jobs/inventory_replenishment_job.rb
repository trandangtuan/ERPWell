class InventoryReplenishmentJob < ApplicationJob
  queue_as :default

  def perform(store_id = nil)
    store_ids = store_id.present? ? [store_id] : Store.pluck(:id)
    store_ids.each { |id| InventoryReplenishmentService.call(id) }
  end
end