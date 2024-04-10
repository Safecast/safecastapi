# frozen_string_literal: true

class DeviceStoryComment < ApplicationRecord
  include Rakismet::Model
  validates :content, presence: true, length: { maximum: 1000 }
  belongs_to :device_story, required: true
  belongs_to :user, required: true

  has_one_attached :image
  validate :image_size
  validate :image_format

  private

  def image_size
    return unless image.attached?
    return if image.blob.byte_size < 10.megabytes

    errors.add(:image, 'is too large (maximum is 10MB)')
  end

  VALID_IMAGE_TYPES = [Mime[:bmp], Mime[:jpeg], Mime[:gif], Mime[:png]].freeze

  def image_format
    return unless image.attached?
    return if Mime::Type.lookup(image.blob.content_type)&.in?(VALID_IMAGE_TYPES)

    errors.add(:image, "is invalid type. Accepted file types: #{VALID_IMAGE_TYPES.map(&:symbol).join(', ')}")
  end
end
