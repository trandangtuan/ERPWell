namespace :inventory do
  desc 'Create draft purchase orders for products below their stock minimum'
  task replenish: :environment do
    InventoryReplenishmentJob.perform_now
  end
end