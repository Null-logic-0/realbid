require "test_helper"

class BidsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @seller = users(:two)
    @product = products(:one)
    @product.user = @seller
    @product.save!

    log_in_as(@user)
  end

  test "should create bid successfully" do
    @user.update!(wallet_balance: 1000)

    valid_bid_amount = @product.bids.maximum(:amount).to_i + 1

    assert_difference("@product.bids.count", 1) do
      post product_bids_path(@product), params: { bid: { amount: valid_bid_amount } }
    end

    assert_redirected_to product_path(@product)
    follow_redirect!

    assert_match /Bid placed successfully/, response.body
  end

  private

  def log_in_as(user)
    post session_path, params: { user: { email: user.email, password: "password1234" } }
    follow_redirect! if response.redirect?
  end
end
