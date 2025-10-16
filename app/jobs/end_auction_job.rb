class EndAuctionJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find_by(id: product_id)
    return if product.nil?

    return if product.ended?

    if product.auction_ended? || Time.current >= product.auction_end_time
      product.end_auction!
    else
      wait = product.auction_end_time - Time.current
      EndAuctionJob.set(wait: wait.seconds).perform_later(product.id) if wait.positive?
    end
  rescue => e
    Rails.logger.error("EndAuctionJob failed for product #{product_id}: #{e.message}")
    raise
  end
end
