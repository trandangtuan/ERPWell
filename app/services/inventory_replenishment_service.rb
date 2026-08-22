class InventoryReplenishmentService
  AUTOMATIC_ORDER_NAME = 'The automatic replenishment stock exists'.freeze
  INTEGER_MAX = 2_147_483_647

  def self.call(store_id)
    new(store_id).call
  end

  def initialize(store_id)
    @store_id = store_id
  end

  def call
    Product.transaction do
      products = Product.where(store_id: @store_id)
                        .where('COALESCE(in_stock, 0) <= COALESCE(in_stock_min, 0)')
                        .where.not(in_stock_max: nil)
                        .lock

      products = products.select do |product|
        current_stock = [product.in_stock.to_i, 0].max
        maximum_stock = product.in_stock_max.to_i
        maximum_stock > current_stock && maximum_stock <= INTEGER_MAX && !open_order_product_ids.include?(product.id)
      end
      return if products.empty?

      purchase_order = automatic_purchase_order
      purchase_order ||= create_purchase_order

      products.each do |product|
        current_stock = [product.in_stock.to_i, 0].max
        quantity = [
        product.in_stock_max.to_i - current_stock,
        product.in_stock_max.to_i
        ].min
        purchase_order.product_purchase_orders.create!(
          product: product,
          quantity: quantity,
          unit_price: product.cost_price || 0,
          discount_percent: 0,
          discount_money: 0,
        #   total_price: quantity * (product.cost_price || 0)
        )
      end

      purchase_order
    end
  end

  private

  def automatic_purchase_order
    PurchaseOrder.where(store_id: @store_id, automatic: true)
                 .where.not(status: [:completed, :canceled])
                 .order(:id).last
  end

  def open_order_product_ids
    ProductPurchaseOrder.joins(:purchase_order)
                        .where(product_id: Product.where(store_id: @store_id).select(:id))
                        .where(purchase_orders: {store_id: @store_id})
                        .where.not(purchase_orders: {status: [:completed, :canceled]})
                        .pluck(:product_id)
  end

  def create_purchase_order
    purchase_order = PurchaseOrder.create!(
      name: AUTOMATIC_ORDER_NAME,
      status: :created,
      automatic: true,
      user: Store.find(@store_id).user,
      store_id: @store_id
    )
    purchase_order.update!(code: "DHN#{purchase_order.id.to_s.rjust(6, '0')}")
    purchase_order
  end
end