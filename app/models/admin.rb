class Admin < ApplicationRecord
  has_secure_password

  validates :email, presence: { message: "Email can't be blank. Please provide a valid email." },
            uniqueness: { message: "This email is already registered." },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Email format is invalid." }

  validates :password, presence: { message: "Password is required." }, length: { minimum: 6, message: "must be at least 6 characters." }
  validates :password_confirmation, presence: { message: "Please confirm your password." }
end
