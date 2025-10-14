class Product < ApplicationRecord
  before_save :capitalize_title

  belongs_to :user

  has_one_attached :product_image

  enum :auction_duration, { "12_hours" => 12,
                            "24_hours" => 24,
                            "48_hours" => 48,
                            "72_hours" => 72 }

  validates :title, presence: true, length: { minimum: 3, allow_blank: true }
  validates :description, presence: true,
            length: { minimum: 10, allow_blank: true, maximum: 200 }
  validates :starting_bid, presence: true
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

  private

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
