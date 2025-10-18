require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @product = products(:one)
    @password = "password1234"
    @user.update!(
      address: "123 Main St",
      city: "Tbilisi",
      country: "Georgia",
      postal_code: "0101",
      phone_number: "+995123456789"
    )
    @product.update(user: @user)
    @product.orders.destroy_all
    log_in_as(@user)
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    image_path = Rails.root.join("test/fixtures/files/b.png")
    product_image = fixture_file_upload(image_path, "image/png")

    post products_path, params: {
      product: {
        title: "New Product",
        description: "Awesome auction item",
        starting_bid: 10,
        auction_duration: "72_hours",
        product_image: product_image

      }

    }

    assert_redirected_to products_path
    follow_redirect!
    assert_match /Product successfully added!/, response.body
  end

  test "should not create product if address incomplete" do
    @user.update(address: nil)
    post products_url, params: {
      product: {
        title: "Invalid Product",
        description: "Should not save",
        starting_bid: 5,
        auction_duration: "72_hours"
      }
    }
    assert_redirected_to edit_user_path(@user)
    assert_match /Please complete your address information/, flash[:alert]
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    product_image = fixture_file_upload(Rails.root.join("test/fixtures/files/b.png"), "image/png")

    patch product_path(@product), params: {
      product: {
        title: "Updated title",
        description: "Existing description",
        starting_bid: 10,
        auction_duration: "72_hours",
        product_image: product_image
      }
    }

    assert_redirected_to products_path
    follow_redirect!
    assert_match /Product successfully updated!/, response.body
    @product.reload
    assert_equal "Updated title", @product.title
  end

  test "should destroy product without orders" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end
    assert_redirected_to products_url
    assert_match /Product successfully deleted!/, flash[:notice]
  end

  test "should not destroy product with orders" do
    order = Order.create!(user: @user, product: @product, amount: 100)
    @product.orders << order
    delete product_url(@product)
    assert_redirected_to products_url
    assert_match /Cannot delete this product/, flash[:alert]
  end

  private

  def log_in_as(user)
    post session_path, params: { user: { email: user.email, password: @password } }

    follow_redirect! if response.redirect?
    session[:expires_at] = 1.hour.from_now
  end
end
