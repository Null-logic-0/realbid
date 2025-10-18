require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    log_in_as(@user)
  end

  test "should create Stripe checkout session" do
    stripe_url = "https://checkout.stripe.com/c/pay/cs_test_a1YNIruBDEl3EJvqTn72SJXl23EJ0omZvFewEbZ3H7GfU9W7ZEEPcbKRxx#fidnandhYHdWcXxpYCc%2FJ2FgY2RwaXEnKSdkdWxOYHwnPyd1blpxYHZxWjA0VkwydU9Adk5MUUdvX0JRX1FyMUNDNW9yMjRCVGpsfFU2f3VHN3FDfUFoZmZUfW9UTlZ1Vn1MNFB0SUdEZE9%2FYklOPGxkYmJNSXVhdEBEaWpNNEtSXW9jNTVcT3M8c0Y8XScpJ2N3amhWYHdzYHcnP3F3cGApJ2dkZm5id2pwa2FGamlqdyc%2FJyZjY2NjY2MnKSdpZHxqcHFRfHVgJz8ndmxrYmlgWmxxYGgnKSdga2RnaWBVaWRmYG1qaWFgd3YnP3F3cGB4JSUl"
    post create_checkout_session_path, params: {
      id: @user.id,
      url: stripe_url,
      price: 200, coins: 250
    }, as: :json

    assert_response :success
  end

  test "should handle canceled payment" do
    get payments_cancel_path
    assert_redirected_to profile_path

    follow_redirect!
    assert_match /Payment canceled./, response.body
  end

  private

  def log_in_as(user)
    post session_path, params: { user: { email: user.email, password: "password1234" } }
    follow_redirect! if response.redirect?
  end
end
