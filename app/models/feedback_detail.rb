require "csv"

class FeedbackDetail < ApplicationRecord
  belongs_to :session
  has_one_attached :image
  validates :category, :description, :location_address, :urgency, :name, :email, presence: true
  validates :description, length: { maximum: 500, minimum: 5 }
  validates :location_address, length: { maximum: 50, minimum: 5 }
  # validates :name, presence: true, format: { with: /\A[a-zA-Z\s]+\z/, message: "only allows letters and spaces" }
  # validates :name, format: { with: /\A[a-zA-Z\s]{50}\z/, message: "must be 2-50 characters, only letters and spaces" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email address" }
  validate :acceptable_image

  def self.to_csv
    attributes = %w[id name category urgency location_address status description created_at ]

    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |feedback|
        csv << attributes.map { |attr| feedback.send(attr) }
      end
    end
  end

  private

  def acceptable_image
    return unless image.attached?

    unless image.blob.byte_size <= 5.megabytes
      errors.add(:image, "is too big (max 5MB)")
    end

    acceptable_types = ["image/jpeg", "image/png", "image/jpg"]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a JPEG, JPG, or PNG")
    end
  end
end
