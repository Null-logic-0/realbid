require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @password = "password1234"
    @initial_balance = @user.wallet_balance
    log_in_as(@user)
  end

  test "should handle checkout.session.completed webhook" do
    mock_event = {
      "type" => "checkout.session.completed",
      "data" => {
        "object" => {
          "metadata" => {
            "user_id" => @user.id.to_s,
            "coins" => "100"
          }
        }
      }
    }

    Stripe::Webhook.define_singleton_method(:construct_event) do |_payload, _sig_header, _secret|
      mock_event
    end

    post webhooks_path,
         params: mock_event.to_json,
         headers: { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "fake_signature" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "Webhook received", body["message"]

    @user.reload
    assert_equal @initial_balance + 100, @user.wallet_balance
  ensure
    class << Stripe::Webhook
      remove_method :construct_event
    end
  end

  private

  def log_in_as(user)
    post session_path, params: { user: { email: user.email, password: @password } }
    follow_redirect! if response.redirect?
    session[:expires_at] = 1.hour.from_now
  end
end
