class User < ApplicationRecord
  has_secure_password

  before_save :capitalize_name, :lowercase_email

  has_one_attached :profile_image, dependent: :destroy

  validates :name, presence: true
  validates :email, format: {
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
    message: "must be a valid email" },
            uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 10, allow_blank: true }

  validate :acceptable_image

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

  def capitalize_name
    self.name = name.capitalize if name.present?
  end

  def lowercase_email
    self.email = email.downcase.strip if email.present?
  end
end
