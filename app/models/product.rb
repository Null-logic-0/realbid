class Product < ApplicationRecord
  before_save :capitalize_title
  after_create :schedule_auction_end

  belongs_to :user
  has_many :bids, dependent: :destroy

  has_one_attached :product_image

  belongs_to :winner, class_name: "User", optional: true

  enum :auction_status, {
    active: "active",
    ended: "ended"
  }

  after_initialize :set_default_status

  enum :auction_duration, { "12_hours" => 12,
                            "24_hours" => 24,
                            "48_hours" => 48,
                            "72_hours" => 72 }

  validates :title, presence: true, length: { minimum: 3, allow_blank: true }
  validates :description, presence: true,
            length: { minimum: 10, allow_blank: true, maximum: 200 }
  validates :starting_bid, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :auction_duration, presence: true
  validate :acceptable_image

  # Auction Time Helpers
  def time_left
    return "Auction not started" if created_at.nil?
    return "Auction ended" if auction_ended?

    time_remaining = auction_end_time - Time.current

    days = (time_remaining / 1.day).floor
    hours = ((time_remaining % 1.day) / 1.hour).floor
    minutes = ((time_remaining % 1.hour) / 1.minute).floor

    if days.positive?
      "#{days}d #{hours}h left"
    elsif hours.positive?
      "#{hours}h #{minutes}m left"
    else
      "#{minutes}m left"
    end
  end

  def auction_end_time
    return nil unless created_at.present? && auction_duration.present?
    created_at + auction_duration_before_type_cast.hours
  end

  def auction_ended?
    auction_end_time.present? && Time.current >= auction_end_time
  end

  # --- Callbacks for Turbo broadcasting ---
  after_commit -> {
    broadcast_prepend_to "products",
                         partial: "products/product",
                         locals: { product: self.reload },
                         target: "products"
  }, on: :create

  after_commit -> {
    broadcast_replace_to "products",
                         partial: "products/product",
                         locals: { product: self.reload },
                         target: "product_#{self.id}"

    broadcast_replace_to "product_#{self.id}_show",
                         partial: "products/product_show",
                         locals: { product: self.reload },
                         target: "product_#{self.id}_show"
  }, on: :update

  after_update_commit :broadcast_auction_status, if: :saved_change_to_auction_status?

  def broadcast_auction_status
    broadcast_replace_to "product_#{id}_show",
                         target: "auction_status_#{id}",
                         partial: "products/auction_status",
                         locals: { product: self }
  end

  after_commit -> {
    # Remove from index
    broadcast_remove_to "products"

    # Remove from show page and trigger redirect if user is there
    Turbo::StreamsChannel.broadcast_replace_to(
      "product_#{id}_show",
      target: "product_#{id}_show",
      html: <<~HTML.html_safe
			  <script>
			    if (window.location.pathname.includes("/products/#{id}")) {
			      window.location.href = "#{Rails.application.routes.url_helpers.products_path}";
			    }
			  </script>
      HTML
    )
  }, on: :destroy

  # end auction operation
  def end_auction!
    return if ended?

    transaction do
      highest = highest_bid

      if highest.present?
        update!(auction_status: "ended", winner: highest.user)

        Order.create!(
          user: highest.user,
          product: self,
          amount: highest.amount
        )

        Notification.new(
          user: highest.user,
          message: "You won the auction for #{title} with a bid of #{highest.amount} coins!"
        ).broadcast

        Notification.new(
          user: user,
          message: "Your product #{title} was sold to #{highest.user.name} for #{highest.amount} coins."
        ).broadcast
      else
        update!(auction_status: "ended")
        Notification.new(user: user, message: "Your auction for #{title} ended with no bids.").broadcast
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to end auction for product #{id}: #{e.message}")
    raise
  end

  def schedule_auction_end
    EndAuctionJob.set(wait: auction_duration_before_type_cast.hours).perform_later(id)
  end

  private

  def set_default_status
    self.auction_status ||= :active
  end

  # highest bid helper
  def highest_bid
    bids.order(amount: :desc).first
  end

  def acceptable_image
    return unless product_image.attached?

    unless product_image.byte_size <= 10.megabyte
      errors.add(:product_image, "must be less than 10MB")
    end

    acceptable_types = %w[image/png image/jpg image/jpeg]
    unless acceptable_types.include? product_image.content_type
      errors.add(:product_image, "must be a png,jpg,jpeg format!")
    end
  end

  def capitalize_title
    self.title = title.capitalize if title.present?
  end
end
