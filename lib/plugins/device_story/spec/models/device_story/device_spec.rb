# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviceStory::Device, type: :model do
  describe '.create' do
    it '' do
      metadata = <<~__JSON__
        {
          "device": 10041,
          "sn": "10041",
          "normalized_sn": "10041",
          "custodian_name": "Larry Richards",
          "location": "Kamata Azatsukinowayama Fukushima City Fukushima  Japan ",
          "dashboard": "https://grafana.safecast.cc/d/8MNBALzWk/device-checker-copy?orgId=1&from=now-7d&to=now&refresh=15m&var-device_urn=pointcast:10041",
          "last_seen": "2019-12-15T13:28:28Z",
          "last_lat": 37.796306,
          "last_lon": 140.514413,
          "last_values": "8.3v 58|19cpm",
          "device_urn": "pointcast:10041"
        }
      __JSON__
      device = described_class.create(metadata: metadata, comment: '_comment_', user_id: 1)
      expect(device.metadata).to include(
        'device' => 10_041,
        'device_urn' => 'pointcast:10041'
      )
    end
  end
end
