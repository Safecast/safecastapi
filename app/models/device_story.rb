# frozen_string_literal: true

class DeviceStory < ApplicationRecord
  validates :device_urn, uniqueness: true
  validates :device_urn, :custodian_name, presence: true
end
