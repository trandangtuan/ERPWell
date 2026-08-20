class ManageController < ApplicationController
  before_action :authenticate_user!
  before_action :current_store

  def index
    store = current_store
    today = Date.current

    set_manage_scopes(store)

    @today_revenue = @invoice_scope.completed.where(date: today).sum(:final_price)
    @month_revenue = @invoice_scope.completed.where(date: today.beginning_of_month..today.end_of_month).sum(:final_price)
    @today_invoice_count = @invoice_scope.where(date: today).count
    @open_purchase_order_count = @purchase_order_scope.where(status: [:created, :checking, :checked, :confirmed, :approved]).count
    @low_stock_count = @product_scope.where("COALESCE(in_stock, 0) <= COALESCE(in_stock_min, 0)").count

    @stats = [
      { label: "Today's revenue", value: @today_revenue, icon: "line-chart", path: invoices_path, money: true },
      { label: "Monthly revenue", value: @month_revenue, icon: "calendar-check-o", path: invoices_path, money: true },
      { label: "Today's invoices", value: @today_invoice_count, icon: "shopping-cart", path: invoices_path },
      { label: "Low-stock products", value: @low_stock_count, icon: "warning", path: products_path }
    ]

    @quick_actions = [
      { title: "Point of sale", text: "Open the POS sales screen", icon: "desktop", path: sale_path, cta: "Open POS", target: "_blank" },
      { title: "Create invoice", text: "Record a new sales order", icon: "shopping-cart", path: new_invoice_path, cta: "Create" },
      { title: "Add product", text: "Update your product catalog", icon: "barcode", path: new_product_path, cta: "Add item" },
      { title: "Stock receipt", text: "Create a warehouse purchase entry", icon: "truck", path: new_purchase_path, cta: "Receive" }
    ]

    @module_cards = [
      { title: "Products", count: @product_scope.count, icon: "archive", path: products_path },
      { title: "Customers", count: Customer.by_store(store.id).count, icon: "users", path: customers_path },
      { title: "Suppliers", count: Supplier.by_store(store.id).count, icon: "handshake-o", path: suppliers_path },
      { title: "Purchase orders", count: @open_purchase_order_count, icon: "clipboard", path: purchase_orders_path },
      { title: "Purchases", count: @purchase_scope.active.count, icon: "truck", path: purchases_path },
      { title: "Staff", count: store.members.count + 1, icon: "user-circle", path: users_path }
    ]

    @recent_invoices = @invoice_scope.includes(:customer, :seller).order(created_at: :desc).limit(5)
    @low_stock_products = @product_scope.order(:in_stock).limit(5)
  end

  def inventory
    set_manage_scopes(current_store)

    @total_products = @product_scope.count
    @active_products = @product_scope.active.count
    @total_stock = @product_scope.sum(:in_stock)
    @low_stock_products = @product_scope.where("COALESCE(in_stock, 0) <= COALESCE(in_stock_min, 0)").order(:in_stock).limit(20)
    @out_of_stock_count = @product_scope.where("COALESCE(in_stock, 0) <= 0").count
    @stock_value = @product_scope.sum("COALESCE(in_stock, 0) * COALESCE(cost_price, 0)")
    @top_stock_products = @product_scope.order(in_stock: :desc).limit(10)
  end

  def sales
    set_manage_scopes(current_store)
    today = Date.current

    @today_sales = @invoice_scope.completed.where(date: today)
    @month_sales = @invoice_scope.completed.where(date: today.beginning_of_month..today.end_of_month)
    @today_revenue = @today_sales.sum(:final_price)
    @month_revenue = @month_sales.sum(:final_price)
    @completed_invoice_count = @month_sales.count
    @average_order_value = @completed_invoice_count.positive? ? (@month_revenue / @completed_invoice_count) : 0
    @recent_invoices = @invoice_scope.includes(:customer, :seller).order(created_at: :desc).limit(20)
    @top_sold_products = ProductInvoice.joins(:invoice, :product)
                                      .where(invoices: { store_id: current_store.id, status: Invoice.statuses[:completed], date: today.beginning_of_month..today.end_of_month })
                                      .group("products.id", "products.name", "products.code")
                                      .select("products.id, products.name, products.code, SUM(product_invoices.quantity) AS sold_quantity, SUM(product_invoices.final_price) AS sold_value")
                                      .order("sold_quantity DESC")
                                      .limit(10)
  end

  def profit
    set_manage_scopes(current_store)
    today = Date.current

    @month_sales = @invoice_scope.completed.where(date: today.beginning_of_month..today.end_of_month)
    @month_revenue = @month_sales.sum(:final_price)
    @month_cost = ProductInvoice.joins(:invoice, :product)
                               .where(invoices: { store_id: current_store.id, status: Invoice.statuses[:completed], date: today.beginning_of_month..today.end_of_month })
                               .sum("COALESCE(product_invoices.quantity, 0) * COALESCE(products.cost_price, 0)")
    @gross_profit = @month_revenue - @month_cost
    @profit_margin = @month_revenue.positive? ? ((@gross_profit.to_f / @month_revenue) * 100).round(1) : 0
    @paid_purchases = @purchase_scope.active.where(date: today.beginning_of_month..today.end_of_month).sum(:paid)
    @profit_products = ProductInvoice.joins(:invoice, :product)
                                    .where(invoices: { store_id: current_store.id, status: Invoice.statuses[:completed], date: today.beginning_of_month..today.end_of_month })
                                    .group("products.id", "products.name", "products.code")
                                    .select("products.id, products.name, products.code, SUM(product_invoices.quantity) AS sold_quantity, SUM(product_invoices.final_price) AS revenue, SUM(COALESCE(product_invoices.quantity, 0) * COALESCE(products.cost_price, 0)) AS cost")
                                    .order("revenue DESC")
                                    .limit(10)
  end

  private

  def set_manage_scopes(store)
    @invoice_scope = Invoice.by_store(store.id)
    @product_scope = Product.by_store(store.id)
    @purchase_order_scope = PurchaseOrder.by_store(store.id)
    @purchase_scope = Purchase.by_store(store.id)
  end
end
