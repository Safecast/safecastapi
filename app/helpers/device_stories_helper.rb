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
end
