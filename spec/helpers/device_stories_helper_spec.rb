# frozen_string_literal: true

RSpec.describe DeviceStoriesHelper, type: :helper do
  device_urn = 'local:12345'
  base_url = 'http://grafana.127.0.0.1.xip.io/d/DFSxrOLWk/safecast-device-details'

  before do
    ENV['DEVICE_STORIES_GRAFANA_BASE_URL'] = base_url
  end

  it 'provides a more details grafana link' do
    url = helper.grafana_more_data(device_urn)
    expect(url).to match '12345'
    expect(url).to match base_url
  end

  it 'provides solo panel iframe urls' do
    url = helper.grafana_iframe(device_urn, :cpm)
    expect(url).to match 'd-solo'
    expect(url).to match '12345'
    expect(url).to match '14'
  end
end
