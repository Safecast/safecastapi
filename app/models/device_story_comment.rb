# frozen_string_literal: true

class DeviceStoryComment < ApplicationRecord
  include Rakismet::Model
  validates :content, presence: true, length: { maximum: 1000 }
  validates :user_id, presence: true
  belongs_to :device_story, required: true
  belongs_to :user, required: true
end
