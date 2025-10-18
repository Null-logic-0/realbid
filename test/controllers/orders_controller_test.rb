require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    log_in_as(@user)
    @product = products(:one)
    @order = Order.create!(user: @user, product: @product)
  end

  test "should get my_orders" do
    get my_orders_orders_path
    assert_response :success
    assert_select "div", /#{@order.product.title}/
  end

  private

  def log_in_as(user)
    post session_path, params: { user: { email: user.email, password: "password1234" } }
    follow_redirect! if response.redirect?
  end
end
