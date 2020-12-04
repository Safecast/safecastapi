# frozen_string_literal: true

class DeviceStory < ApplicationRecord
  validates :device_urn, uniqueness: true
  validates :device_urn, :custodian_name, presence: true
  has_many  :device_story_comments
  accepts_nested_attributes_for :device_story_comments
end
