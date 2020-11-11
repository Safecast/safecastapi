# frozen_string_literal: true

module DeviceStoriesHelper
  def grafana_panel(name)
    panels = {
      cpm: 14,
      map: 8
    }
    panels[name]
  end

  def grafana_url(variant = nil)
    url = ENV['DEVICE_STORIES_GRAFANA_BASE_URL'] || 'https://grafana.safecast.cc/d/DFSxrOLWk/safecast-device-details'
    uri = URI.parse(url)
    if variant == :solo
      parts = uri.path.split('/')
      parts[1] = 'd-solo'
      uri.path = parts.join('/')
    end
    uri
  end

  def grafana_more_data(device_urn)
    url = grafana_url
    args = {
      from: 'now-90d',
      to: 'now',
      refresh: '15',
      'var-device_urn': device_urn
    }
    url.query = args.to_query
    url.to_s.html_safe
  end

  def grafana_iframe(device_urn, panel_id)
    url = grafana_url(:solo)
    args = {
      from: 'now-90d',
      to: 'now',
      refresh: '15',
      'var-device_urn': device_urn,
      panelId: panel_id
    }
    url.query = args.to_query
    url.to_s.html_safe
  end

  def last_battery_value(last_values)
    last_values[0..last_values.index('v') - 1] unless last_values.index('v').nil?
  end

  def last_cpm_values(last_values)
    index_v = last_values.index('v')
    index_c = last_values.index('c')
    if index_v.nil? && !index_c.nil?
      last_values[0..index_c - 1]
    elsif !index_c.nil?
      last_values[index_v + 1..index_c - 1]
    end
  end

  def last_air_quality_values(last_values)
    index_c = last_values.index('c')
    index_u = last_values.index('u')
    if index_c && index_u
      last_values[index_c + 3..index_u - 1]
    elsif index_u
      last_values[0..index_u - 1]
    end
  end
end
