class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error("Stripe webhook error: #{e.message}")
      return render json: { error: e.message }, status: 400
    end

    case event["type"]
    when "checkout.session.completed"
      session = event["data"]["object"]
      handle_checkout_session(session)
    end

    render json: { message: "Webhook received" }, status: 200
  end

  private

  def handle_checkout_session(session)
    user_id = session["metadata"]["user_id"]
    coins = session["metadata"]["coins"].to_i

    # Rails.logger.info("✅ Webhook received: user_id=#{user_id}, coins=#{coins}")

    return if user_id.blank? || coins.zero?

    user = User.find_by(id: user_id)
    return unless user

    user.wallet_balance += coins
    user.save!
    # Rails.logger.info("💰 Updated wallet: #{user.wallet_balance}")
  end
end
