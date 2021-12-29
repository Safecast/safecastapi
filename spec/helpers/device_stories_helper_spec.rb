# frozen_string_literal: true

RSpec.describe DeviceStoriesHelper, type: :helper do
  device_urn = 'local:12345'
  base_url = 'http://grafana.127.0.0.1.xip.io/d/DFSxrOLWk/safecast-device-details'

  before do
    ENV['DEVICE_STORIES_GRAFANA_BASE_URL'] = base_url
  end

  describe '.grafana_more_data' do
    it 'provides a more details grafana link' do
      url = helper.grafana_more_data(DeviceStory.new(device_urn: device_urn))
      expect(url).to match(base_url).and match(Rack::Utils.escape(device_urn))
    end
  end

  describe '.grafana_iframe' do
    it 'provides solo panel iframe urls' do
      url = helper.grafana_iframe(device_urn, :cpm)
      expect(url).to match 'd-solo'
      expect(url).to match '12345'
      expect(url).to match '14'
    end
  end

  describe '.sensor_data_by_sensors' do
    let(:sensor_data) { JSON.parse(file_fixture('sensor_data.json').read) }

    it 'converts sensor data by sensor names' do
      res = helper.sensor_data_by_sensors(sensor_data)
      expect(res).to include(
        'temperature_C' => [{
          name: 'temperature_C',
          data: include(
            '2021-03-08 00' => 16.91751828158859,
            '2021-03-08 12' => 16.28823545399834
          )
        }],
        'temperature_F' => [{
          name: 'temperature_F',
          data: include(
            '2021-03-08 12' => 61.318823817197014
          )
        }],
        'humidity' => [],
        'charging' => []
      )
    end
  end

  describe '.sensor_last_location' do
    before do
      # Remove this environment variable to fore elasticsearch client
      # to request to localhost.
      @old_elasticsearch_url = ENV.delete('ELASTICSEARCH_URL')
      WebMock::Config.instance.allow_localhost = false
      stub_request(:get, 'http://localhost:9200/ingest-measurements-*/_doc/_search')
        .to_return(status: 200, body: query_last_sensor_location_response, headers: { 'Content-Type': 'application/json' })

      assign(:device_story, DeviceStory.new(device_urn: '_device_urn_'))
    end

    after do
      WebMock::Config.instance.allow_localhost = true
      ENV['ELASTICSEARCH_URL'] = @old_elasticsearch_url
    end

    context 'when there is a hit' do
      let(:query_last_sensor_location_response) { String.new(<<~JSON) }
        {"took":9919,"timed_out":false,"_shards":{"total":91,"successful":91,"skipped":0,"failed":0},"hits":{"total":{"value":10000,"relation":"gte"},"max_score":null,"hits":[{"_index":"ingest-measurements-2021-03-28","_type":"_doc","_id":"p7nkdngBj2uUTIA-3o17","_score":null,"_source":{"device_urn":"pointcast:10018","device_class":"pointcast","device_sn":"POINTCAST #10018","device":10018,"when_captured":"2021-03-28T03:33:33Z","loc_lat":35.615814,"loc_lon":139.625711,"loc_alt":24,"loc_olc":"8Q7XJJ8G+87G","env_temp":22.3,"service_uploaded":"2021-03-28T03:33:33Z","service_transport":"pointcast:103.67.223.4","service_handler":"i-051a2a353509414f0","@timestamp":"2021-03-28T03:33:33Z","ingest":{"location":{"lat":35.615814,"lon":139.625711}}},"sort":[1616902413000]}]}}
      JSON

      it 'return latest device location' do
        expect(helper.sensor_last_location).to include('lat' => 35.615814, 'lon' => 139.625711)
      end
    end

    context 'when there is no hit' do
      let(:query_last_sensor_location_response) { String.new(<<~JSON) }
        {"took":9919,"timed_out":false,"_shards":{"total":91,"successful":91,"skipped":0,"failed":0},"hits":{"hits":[]}}
      JSON

      it 'return latest device location' do
        expect(helper.sensor_last_location).to be_empty
      end
    end
  end
end
