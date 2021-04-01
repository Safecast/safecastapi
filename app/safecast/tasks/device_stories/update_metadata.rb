# frozen_string_literal: true

module Tasks
  module DeviceStories
    class UpdateMetadata
      def self.call
        new.call
      end

      def call
        each_metadata(parse(fetch(devices_uri))) do |device_urn, metadata|
          find_or_update_device(device_urn, metadata)
        end
      end

      private

      def find_or_update_device(device_urn, metadata)
        device = DeviceStory.find_or_initialize_by(device_urn: device_urn)
        device.update_from_ttserve(metadata)
        device.save!
      rescue ActiveRecord::RecordInvalid
        Rails.logger.warn "Could not update device metadata for device_urn[#{device_urn}]"
      end

      def each_metadata(metadatas)
        metadatas.each do |metadata|
          device_urn = metadata['device_urn']
          unless device_urn
            Rails.logger.warn 'Could not find device_urn'
            next
          end
          yield device_urn, metadata
        end
      end

      def parse(json)
        JSON.parse(json)
      end

      def fetch(uri)
        res = Net::HTTP.get_response(uri)
        raise "Could not fetch device metadata from ttserve. #{res}" unless res.is_a?(Net::HTTPOK)

        res.body
      end

      def devices_uri
        URI(ENV.fetch('DEVICE_STORY_DEVICES_URI', 'https://tt.safecast.org/devices'))
      end
    end
  end
end
