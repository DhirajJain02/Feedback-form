require "csv"

class FeedbackDetail < ApplicationRecord
  belongs_to :session
  has_one_attached :image
  validates :category, :description, :location_address, :urgency, :name, :email, presence: true
  validates :description, length: { maximum: 500, minimum: 5 }
  validates :location_address, length: { maximum: 50, minimum: 5 }
  validates :name, presence: true, format: { with: /\A[a-zA-Z\s]+\z/, message: "only allows letters and spaces" }, length: { minimum: 3, maximum: 30 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email address" }
  validate :acceptable_image

  CATEGORIES = ['Infrastructure (e.g. Roads, lighting)', 'Environment (e.g, Waste, greenery)', 'Event Suggestion',
                'General Suggestion/ Suggestion', 'Security Concern', 'Other'].freeze

  URGENCY_LEVELS = ['Low Priority', 'Medium Priority', 'High Priority', 'Critical (Requires immediate attention)'].freeze

  validates :category, presence: true, inclusion: { in: CATEGORIES, message: "%{value} is not a valid category" }
  validates :urgency, presence: true, inclusion: { in: URGENCY_LEVELS, message: "%{value} is not a valid urgency level" }

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

    if image.blob.byte_size > 5.megabytes
      errors.add(:image, "is too big (max 5MB)")
    end

    acceptable_types = ["image/jpeg", "image/png", "image/jpg"]
    unless acceptable_types.include?(image.blob.content_type)
      errors.add(:image, "must be a JPEG, JPG, or PNG")
    end
  end
end
