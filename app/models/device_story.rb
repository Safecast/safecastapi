# frozen_string_literal: true

class DeviceStory < ApplicationRecord
  validates :device_urn, uniqueness: true, presence: true
  has_many  :device_story_comments, dependent: :destroy

  def update_from_ttserve(metadata)
    self.device_id = metadata['device']
    self.last_seen = metadata['when_captured']
    self.custodian_name = metadata['device_contact_name']

    last_lon, last_lat = metadata.values_at('loc_lon', 'loc_lat')
    return unless last_lon.present? && last_lat.present?

    self.last_location = "POINT(#{last_lon} #{last_lat})"
    self.last_location_name = metadata['location']
  end
end
