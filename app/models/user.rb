class User < ApplicationRecord
  has_secure_password

  before_save :capitalize_name, :lowercase_email

  validates :name, presence: true
  validates :email, format: {
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
    message: "must be a valid email" },
            uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 10, allow_blank: true }

  private

  def capitalize_name
    self.name = name.capitalize if name.present?
  end

  def lowercase_email
    self.email = email.downcase.strip if email.present?
  end
end
