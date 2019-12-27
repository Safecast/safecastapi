# frozen_string_literal: true

module DeviceStory
  class Device < ApplicationRecord
    self.table_name = 'device_story_devices'

    validates :device_urn, presence: true, uniqueness: true
    validates :metadata, presence: true
  end
end
