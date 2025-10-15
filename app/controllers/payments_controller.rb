class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create
    price = params[:price].to_i
    coins = params[:coins].to_i

    customer = Stripe::Customer.create(
      email: current_user&.email,
      name: current_user&.name
    )

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      customer: customer.id,
      line_items: [ {
                     price_data: {
                       currency: "usd",
                       product_data: {
                         name: "#{coins} Coins"
                       },
                       unit_amount: price
                     },
                     quantity: 1
                   } ],
      mode: "payment",
      success_url: payments_success_url,
      cancel_url: payments_cancel_url,
      metadata: {
        user_id: current_user&.id.to_s,
        coins: coins.to_s
      }
    )
    # Rails.logger.info "===================="
    # Rails.logger.info "Stripe Session Created:"
    # Rails.logger.info session.to_json
    # Rails.logger.info "===================="
    render json: { url: session.url }
  end

  def success
    price = params[:price].to_i
    coins = params[:coins].to_i

    if current_user
      current_user&.wallet_balance += coins
      current_user&.save!
    end

    redirect_to profile_path, notice: "Payment successful!"
  end

  def cancel
    redirect_to profile_path, alert: "Payment canceled."
  end
end
