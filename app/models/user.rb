class User < ApplicationRecord
  has_secure_password

  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy

  before_save :upcase_name, :lowercase_email

  has_one_attached :profile_image, dependent: :destroy

  has_many :bids

  has_many :notifications, dependent: :destroy

  validates :name, presence: true
  validates :email, format: {
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
    message: "must be a valid email" },
            uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 10, allow_blank: true }

  validates :phone_number, format: {
    with: /\A\+?[0-9\s\-\(\)]{7,20}\z/,
    message: "must be a valid phone number"
  }

  validate :acceptable_image

  def total_order_amount
    orders.sum(:amount)
  end

  def my_balance
    # Sum of all order amounts for products this user sold
    Order.joins(:product)
         .where(products: { user_id: id })
         .sum(:amount)
  end

  private

  def acceptable_image
    return unless profile_image.attached?

    unless profile_image.byte_size <= 8.megabyte
      errors.add(:profile_image, "must be less than 8MB")
    end

    acceptable_types = %w[image/png image/jpg image/jpeg]
    unless acceptable_types.include? profile_image.content_type
      errors.add(:profile_image, "must be a png, jpg, or jpeg format!")
    end
  end

  def upcase_name
    self.name = name.upcase if name.present?
  end

  def lowercase_email
    self.email = email.downcase.strip if email.present?
  end
end
