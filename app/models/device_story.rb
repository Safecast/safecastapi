# frozen_string_literal: true

class DeviceStory < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  validates :device_urn, uniqueness: true
  validates :device_urn, :custodian_name, presence: true
  DeviceStory.import force: true
end
