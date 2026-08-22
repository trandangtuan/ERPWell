class Invoice < ApplicationRecord
  after_save :adjust_inventory, if: :completed_status_changed?

  belongs_to :customer, optional: true
  belongs_to :user
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :store

  has_many :product_invoices, dependent: :delete_all
  has_many :products, through: :product_invoices

  validates :code, uniqueness: {scope: :store}, length: {minimum: 2, maximum: 32}, :allow_blank => true

  enum status: { created: 0, completed: 1, canceled: 2 }
  scope :by_store, -> (store_id) { where(store_id: store_id) }
  scope :active, -> (){
      where(status: [:completed])
  }
  self.per_page = 10

  def update_price
    total = 0
    self.product_invoices.each do |pp|
      final_price = pp.quantity * pp.unit_price - pp.discount_money
      pp.final_price = final_price
      total += final_price
    end

    self.sale_off = 0 if self.sale_off.nil?
    self.paid = 0 if self.paid.nil?
    self.total_price = total
    self.final_price = total - sale_off
    self.given_money = 0 if self.given_money.nil?
    self.returned_money = self.given_money - self.final_price
  end

  private

  def completed_status_changed?
    completed? && inventory_adjusted_at.nil? && (saved_change_to_status? || new_record?)
  end

  def adjust_inventory
    transaction do
      product_invoices.includes(:product).each do |product_invoice|
        next unless product_invoice.product

        product_invoice.product.with_lock do
          product_invoice.product.update!(in_stock: (product_invoice.product.in_stock || 0) - product_invoice.quantity.to_i)
        end
      end

      update_column(:inventory_adjusted_at, Time.current)
      InventoryReplenishmentService.call(store_id)
    end
  end
end
