# frozen_string_literal: true

module DeviceStoriesHelper
  def grafana_panel(name)
    panels = {
      cpm: { id: 14, dashboard: '/d/DFSxrOLWk/safecast-device-details' },
      map: { id: 8, dashboard: '/d/DFSxrOLWk/safecast-device-details' },
      air_quality: { id: 15, dashboard: '/d/7wsttvxGk/safecast-airnote' },
      air_quality_map: { id: 21, dashboard: '/d/7wsttvxGk/safecast-airnote' }
    }
    panels[name]
  end

  def grafana_url(variant, panel)
    url = (ENV['DEVICE_STORIES_GRAFANA_BASE_URL'] || 'https://grafana.safecast.cc') + panel[:dashboard]
    uri = URI.parse(url)
    if variant == :solo
      parts = uri.path.split('/')
      parts[1] = 'd-solo'
      uri.path = parts.join('/')
    end
    uri
  end

  def grafana_more_data(device_urn)
    includes_note = device_urn.include? 'note:dev'
    url = grafana_url(nil, grafana_panel(includes_note ? :air_quality : :cpm))
    args = {
      from: 'now-90d',
      to: 'now',
      'var-device_urn': device_urn
    }
    url.query = args.to_query
    url.to_s.html_safe
  end

  def grafana_iframe(device_urn, panel_name)
    url = grafana_url(:solo, grafana_panel(panel_name))
    args = {
      from: 'now-90d',
      to: 'now',
      'var-device_urn': device_urn,
      panelId: grafana_panel(panel_name)[:id]
    }
    url.query = args.to_query
    url.to_s.html_safe
  end

  def last_battery_value(last_values)
    last_values[0..last_values.index('v') - 1] unless last_values.index('v').nil?
  end

  def last_air_quality_values(last_values)
    index_v = last_values.index('v')
    index_c = last_values.index('c')
    index_u = last_values.index('u')
    if index_c && index_u
      last_values[index_c + 3..index_u - 1]
    elsif index_v && index_u
      last_values[index_v + 1..index_u - 1]
    elsif index_u
      last_values[0..index_u - 1]
    end
  end

  # The names should correspond to the names in the query
  CATEGORY_SENSOR_NAMES = {
    'radiation_sensors' => %w(lnd_7128ec lnd_7318c lnd_712u lnd_7318u lnd_78017w lnd7318u lnd7128c),
    'radiation_mrem' => %w(lnd_7128ec_mrem lnd_7318c_mrem lnd_712u_mrem lnd_7318u_mrem lnd_78017w_mrem lnd7318u_mrem lnd7128c_mrem),
    'air_sensors' => %w(pms_pm10_0 pms_pm02_5 pms_pm01_0),
    'bat_voltage' => ['bat_voltage'],
    'temperature_C' => ['temperature_C'],
    'temperature_F' => ['temperature_F'],
    'humidity' => ['humidity'],
    'pressure' => ['pressure'],
    'charging' => ['charging'],
    'bat_charge' => ['bat_charge']
  }.freeze

  def sensor_data_by_sensors(sensor_data)
    data_by_dates = convert_by_dates(sensor_data.dig('aggregations', 'sensor_data', 'buckets') || [])
    CATEGORY_SENSOR_NAMES.transform_values do |names|
      names.each_with_object([]) do |name, arr|
        arr << { name: name, data: data_by_dates[name] } if data_by_dates.key?(name)
      end
    end
  end

  def convert_by_dates(buckets)
    buckets.each_with_object(Hash.new { |h, k| h[k] = {} }) do |bucket, hsh|
      date = bucket['key_as_string']
      bucket.except('key', 'key_as_string', 'doc_count').each do |name, data|
        value = data['value']
        hsh[name][date] = value if value.present?
      end
    end
  end

  def sensor_last_location
    res = IngestMeasurement.query_last_sensor_location(@device_story.device_urn)
    hits = res.response.hits.hits
    hits.empty? ? {} : hits.first._source.ingest.location&.to_hash
  end
end
