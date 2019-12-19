# frozen_string_literal: true

module DeviceStory
  module Tasks
    class UpdateDeviceMetadata
      class << self
        def call
          new.call
        end
      end

      def call
        each_metadata(parse(fetch(devices_uri))) do |device_urn, metadata|
          begin
            device = DeviceStory::Device.find_by(device_urn: device_urn)
            if device
              device.update!(metadata: metadata)
            else
              DeviceStory::Device.create!(device_urn: device_urn, metadata: metadata)
            end
          rescue ActiveRecord::RecordInvalid
            warn "Could not update device metadata for #{device_urn}."
          end
        end
      end

      private

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
      rescue Psych::SyntaxError
        warn 'Could not parse device metadata.'
        []
      end

      def fetch(uri)
        res = Net::HTTP.get_response(uri)
        if res.is_a?(Net::HTTPOK)
          res.body
        else
          warn 'Could not fetch device metadata from ttserve.'
          '{}'
        end
      end

      def devices_uri
        URI(ENV.fetch('DEVICE_STORY_DEVICES_URI', 'https://tt.safecast.org/devices'))
      end
    end
  end
end
