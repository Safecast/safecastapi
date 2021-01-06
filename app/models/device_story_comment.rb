# frozen_string_literal: true

class DeviceStoryComment < ApplicationRecord
  include Rakismet::Model
  validates :content, presence: true, length: { maximum: 1000 }
  validates :user_id, presence: true
  belongs_to :device_story, require: true
  belongs_to :user, require: true
end
