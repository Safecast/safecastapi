# frozen_string_literal: true

class DeviceStoryComment < ApplicationRecord
  include Rakismet::Model
  validates :content, presence: true, length: { maximum: 1000 }
  validates :user_id, presence: true
  belongs_to :device_story, required: true
  belongs_to :user, required: true
  mount_uploader :image, DeviceStoryImageUploader
  validate :image_size_validation

  def image_size_validation
    if image.size > 10.megabytes
      errors.add(:base, "File size is too large (maximum is 10MB)")
    end
  end
end
