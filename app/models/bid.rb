class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :amount, numericality: { greater_than: 0 }
  validate :higher_than_current_bid
  validate :sufficient_balance

  after_create :handle_wallets_and_refunds

  after_commit -> {
    broadcast_prepend_to "bids",
                         partial: "bids/bid",
                         locals: { product: self.reload },
                         target: "bids"
  }, on: :create

  private

  def higher_than_current_bid
    return if amount.nil?

    highest_bid = product&.bids&.maximum(:amount) || 0
    if amount <= highest_bid
      errors.add(:amount, "must be higher than the current highest bid ($#{highest_bid})")
    end
  end

  def sufficient_balance
    return if user.nil? || amount.nil?

    previous_user_bid = product.bids.where(user: user).maximum(:amount) || 0
    required_amount = amount - previous_user_bid

    if user.wallet_balance < required_amount
      errors.add(:base, "You don't have enough balance to increase your bid.")
    end
  end

  def handle_wallets_and_refunds
    return if user.nil? || amount.nil?

    #  Deduct only the difference from the current user's wallet
    previous_user_bid = product.bids.where(user: user).where.not(id: id).maximum(:amount) || 0
    difference = amount.to_i - previous_user_bid.to_i
    user.update!(wallet_balance: user.wallet_balance.to_i - difference)

    #  Refund the actual previous highest bidder (before this bid)
    previous_highest_bid = product.bids
                                  .where.not(id: id) # ignore this bid
                                  .order(amount: :desc)
                                  .first # get the highest bid before this one

    if previous_highest_bid&.user && previous_highest_bid.user != user
      previous_highest_bid.user.update!(
        wallet_balance: previous_highest_bid.user.wallet_balance.to_i + previous_highest_bid.amount.to_i
      )
    end
  end
end
