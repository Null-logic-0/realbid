class BidsController < ApplicationController
  before_action :set_product
  before_action :require_login
  before_action :prevent_seller_bidding, only: [ :create ]

  def create
    if @product.ended? || @product.auction_ended?
      redirect_to product_path(@product), alert: "This auction has already ended."
      return
    end
    @bid = @product.bids.build(bid_params.merge(user: current_user))

    if @bid.save
      Notification.new(
        user: @product.user,
        message: "#{current_user&.name} placed a bid of #{@bid.amount} coins on your product #{@product.title}"
      ).broadcast

      redirect_to product_path(@product), notice: "Bid placed successfully."
    else
      redirect_to product_path(@product), alert: @bid.errors.full_messages.join(", ")
    end
  end

  private

  def prevent_seller_bidding
    if @product.user == current_user
      redirect_to product_path(@product), alert: "You cannot bid on your own product."
    end
  end

  def set_product
    @product = Product.find(params[:product_id])
  end

  def bid_params
    params.require(:bid).permit(:amount)
  end
end
