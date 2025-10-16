namespace :auctions do
  desc "End auctions that have passed their end time but are still active"
  task end_expired: :environment do
    Product.where(auction_status: "active").find_each do |product|
      if product.auction_end_time.present? && Time.current >= product.auction_end_time
        Rails.logger.info("Ending expired auction for product #{product.id}")
        product.end_auction!
      end
    end
  end
end
