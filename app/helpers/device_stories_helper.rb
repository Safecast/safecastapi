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
      refresh: '15',
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
      refresh: '15',
      'var-device_urn': device_urn,
      panelId: grafana_panel(panel_name)[:id]
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

  def query_elasticsearch()
    IngestMeasurement.search "query":
                                 {
                                     "bool": {
                                         "must": [
                                             {
                                                 "range": {
                                                     "service_uploaded": {
                                                         "gte": "now-2w",
                                                         "lte": "now"
                                                     }
                                                 }
                                             },
                                             {
                                                 "match": {
                                                     "device_urn": @device_story.device_urn
                                                 }
                                             }
                                         ]
                                     }
                                 },
                             "size": 0,
                             "aggs":
                                 {
                                     "my_buckets":
                                         {
                                             "composite":
                                                 {
                                                     "size": 1000,
                                                     "sources":
                                                         [
                                                             {
                                                                 "date":
                                                                     {
                                                                         "date_histogram":
                                                                             {
                                                                                 "field": "when_captured",
                                                                                 "interval":  "hour"
                                                                             }
                                                                     }

                                                             }
                                                         ]
                                                 },
                                             "aggregations":
                                                 {
                                                     "lnd_7318u":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_7318u"
                                                                 }
                                                         },
                                                     "lnd_712u":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_712u"
                                                                 }
                                                         },
                                                     "lnd_7128ec":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_7128ec"
                                                                 }
                                                         },
                                                     "lnd_7318c":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_7318c"
                                                                 }
                                                         },
                                                     "lnd_78017w":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_78017w"
                                                                 }
                                                         },
                                                     "lnd_7128c":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_7128c"
                                                                 }
                                                         }
                                                 }
                                         }
                                 }
  end

  def query_elasticsearch_after(after)
    IngestMeasurement.search "query":
                                 {
                                     "bool": {
                                         "must": [
                                             {
                                                 "range": {
                                                     "service_uploaded": {
                                                         "gte": "now-2w",
                                                         "lte": "now"
                                                     }
                                                 }
                                             },
                                             {
                                                 "match": {
                                                     "device_urn": @device_story.device_urn
                                                 }
                                             }
                                         ]
                                     }
                                 },
                             "aggs":
                                 {
                                     "my_buckets":
                                         {
                                             "composite":
                                                 {
                                                     "size": 10000,
                                                     "sources":
                                                         [
                                                             {
                                                                 "date":
                                                                     {
                                                                         "date_histogram":
                                                                             {
                                                                                 "field": "when_captured",
                                                                                 "interval":  "hour",
                                                                                 "format": "H"
                                                                             }
                                                                     }

                                                             }
                                                         ],
                                                     "after": { "date": after["date"] }
                                                 },
                                             "aggregations":
                                                 {
                                                     "lnd_7318u":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_7318u"
                                                                 }
                                                         },
                                                     "lnd_712u":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_712u"
                                                                 }
                                                         },
                                                     "lnd_7128ec":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_7128ec"
                                                                 }
                                                         },
                                                     "lnd_7318c":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_7318c"
                                                                 }
                                                         },
                                                     "lnd_78017w":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_78017w"
                                                                 }
                                                         },
                                                     "lnd_7128c":
                                                         {
                                                             "avg":
                                                                 {
                                                                     "field": "lnd_7128c"
                                                                 }
                                                         }
                                                 }
                                         }
                                 }
  end

  def get_elasticsearch_hash(max_composites, after = nil)
    q = after ? query_elasticsearch_after(after) : query_elasticsearch()
    all_hashes = []
    hash_lnd_7318u = {}
    hash_lnd_712u = {}
    hash_lnd_7128ec = {}
    hash_lnd_7318c = {}
    hash_lnd_78017w = {}
    hash_lnd_7128c = {}
    return all_hashes if q.response["aggregations"]["my_buckets"]["buckets"].size < 1
    after_key = q.response["aggregations"]["my_buckets"]["after_key"]
    q.response["aggregations"]["my_buckets"]["buckets"].each do |aggr|
      date = Time.at(aggr["key"]["date"] / 1000.0).strftime('%Y-%m-%d %H')
      avg_lnd_7318u_value = aggr["lnd_7318u"]["value"]
      avg_lnd_712u_value = aggr["lnd_712u"]["value"]
      avg_lnd_7128ec_value = aggr["lnd_7128ec"]["value"]
      avg_lnd_7318c_value = aggr["lnd_7318c"]["value"]
      avg_lnd_78017w_value = aggr["lnd_78017w"]["value"]
      avg_lnd_7128c_value = aggr["lnd_78017w"]["value"]
      hash_lnd_7318u.merge!(date => avg_lnd_7318u_value)
      hash_lnd_712u.merge!(date => avg_lnd_712u_value)
      hash_lnd_7128ec.merge!(date => avg_lnd_7128ec_value)
      hash_lnd_7318c.merge!(date => avg_lnd_7318c_value)
      hash_lnd_78017w.merge!(date => avg_lnd_78017w_value)
      hash_lnd_7128c.merge!(date => avg_lnd_7128c_value)
    end
    all_hashes.push({"name": "lnd_7128ec", "data": hash_lnd_7128ec})
    all_hashes.push({"name": "lnd_7318c", "data": hash_lnd_7318c})
    all_hashes.push({"name": "lnd_712u", "data": hash_lnd_712u})
    all_hashes.push({"name": "lnd_7318u", "data": hash_lnd_7318u})
    all_hashes.push({"name": "lnd_78017w", "data": hash_lnd_78017w})
    all_hashes.push({"name": "lnd_7128c", "data": hash_lnd_7128c})
    if after_key == nil || max_composites <= 0
      return all_hashes
    else
      puts "DATE: " + after_key["date"].to_s + max_composites.to_s
      get_elasticsearch_hash(max_composites - 1, after_key) + all_hashes
    end
  end

  def query_all_sensors
    get_elasticsearch_hash(20)
  end
end
