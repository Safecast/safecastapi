# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeviceStory::Device, type: :model do
  describe '.create' do
    it 'should create from metadata' do
      metadata = {
        "device" => 10041,
        "sn" => "10041",
        "normalized_sn" => "10041",
        "custodian_name" => "Larry Richards",
        "location" => "Kamata Azatsukinowayama Fukushima City Fukushima  Japan ",
        "dashboard" => "https://grafana.safecast.cc/d/8MNBALzWk/device-checker-copy?orgId=1&from=now-7d&to=now&refresh=15m&var-device_urn=pointcast:10041",
        "last_seen" => "2019-12-15T13:28:28Z",
        "last_lat" => 37.796306,
        "last_lon" => 140.514413,
        "last_values" => "8.3v 58|19cpm",
        "device_urn" => "pointcast:10041"
      }
      device = described_class.create(
        device_urn: 'pointcast:10041',
        metadata: metadata.as_json,
        comment: '_comment_',
        user_id: 1
      )
      expect(device).to have_attributes(
        device_id: 10_041,
        last_location: be_present,
        last_values: '8.3v 58|19cpm'
      )
      expect(device.last_location.latitude).to eq(37.796306)
      expect(device.last_location.longitude).to eq(140.514413)
      expect(device.metadata).to include(
        'device' => 10_041,
        'device_urn' => 'pointcast:10041'
      )
    end
  end
end
