# frozen_string_literal: true

class DeviceStoryComment < ApplicationRecord
  include Rakismet::Model
  belongs_to :device_story
  belongs_to :user
end
