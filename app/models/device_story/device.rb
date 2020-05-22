# frozen_string_literal: true

module DeviceStory
  class Device < ApplicationRecord
    self.table_name = 'device_story_devices'

    validates :device_urn, presence: true, uniqueness: true
    validates :metadata, presence: true

    format_dates :last_seen, format: '%Y/%m/%d %H:%M:%S %z'

    before_save :update_from_metadata

    def location
      metadata['location']
    end

    def last_seen
      DateTime.parse(metadata['last_seen'])
    end

    private

    def update_from_metadata
      self.device_id = metadata['device']
      points = metadata.values_at('last_lon', 'last_lat')
      raise ActiveRecord::RecordInvalid, 'Missing longitude or latitude' if points.any?(&:blank?)

      self.last_location = "POINT(#{points.join(' ')})"
      self.last_values = metadata['last_values']
    end
  end
end
