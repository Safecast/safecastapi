# frozen_string_literal: true

module Tasks
  module DeviceStory
    class UpdateMetadata
      class << self
        def call
          new.call
        end
      end

      def call
        each_metadata(parse(fetch(devices_uri))) do |device_urn, metadata|
          find_or_update_device(device_urn, metadata)
        rescue ActiveRecord::RecordInvalid
          warn "Could not update device metadata for #{device_urn}."
        end
      end

      private

      def find_or_update_device(device_urn, metadata)
        device = DeviceStory.find_by(device_urn: device_urn)
        if device
          device.update!(metadata: metadata)
        else
          DeviceStory.create!(device_urn: device_urn, metadata: metadata)
        end
      end

      def each_metadata(metadatas)
        metadatas.each do |metadata|
          device_urn = metadata['device_urn']
          unless device_urn
            warn 'Could not find device_urn.'
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
