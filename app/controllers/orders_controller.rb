class OrdersController < ApplicationController
  before_action :require_login

  def my_orders
    @orders = current_user&.orders&.includes(:product)&.order(created_at: :desc)
  end
end
