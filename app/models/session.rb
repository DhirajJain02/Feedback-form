class Session < ApplicationRecord
  has_many :feedback_details
  # include ActiveModel::Model
  # attr_accessor :phone_number, :otp, :verified
  # validates :phone_number,
  #           presence: true,
  #           format: { with: /\A\d{10}\z/, message: "must be exactly 10 digits" }

  def generate_auth_token!
    self.auth_token = SecureRandom.hex(20)
    self.token_expires_at = 24.hours.from_now
    save!
  end

  def token_valid?(token)
    self.auth_token == token && token_expires_at && token_expires_at.future?
  end
end
