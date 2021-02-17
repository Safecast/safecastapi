# frozen_string_literal: true

class IngestMeasurement
  extend ActiveModel::Naming
  include Elasticsearch::Model

  index_name 'ingest-measurements-*'
  document_type '_doc'

  class << self
    def data_for(query)
      search(query: query).results.map(&:_source)
    end

    def query_sensor_data(device_urn) # rubocop:disable Metrics/MethodLength
      search "query":
                 { "bool": {
                   "filter": [
                     {
                       "range": {
                         "@timestamp": {
                           "gte": 'now-8w',
                           "lte": 'now',
                           "format": 'epoch_millis'
                         }
                       }
                     },
                     {
                       "query_string": {
                         "analyze_wildcard": true,
                         "query": "device_urn:" + "\"" + device_urn + "\"" # rubocop:disable all
                       }
                     }
                   ]
                 } },
             "aggs": {
               "sensor_data": {
                 "date_histogram": {
                   "interval": '6h',
                   "field": '@timestamp',
                   "min_doc_count": 0,
                   "extended_bounds": {
                     "min": 'now-8w',
                     "max": 'now'
                   },
                   "format": 'epoch_millis'
                 },
                 "aggs": {
                   "lnd_7128ec": {
                     "avg": {
                       "field": 'lnd_7128ec'
                     }
                   },
                   "lnd_7318c": {
                     "avg": {
                       "field": 'lnd_7318c'
                     }
                   },
                   "lnd_712u": {
                     "avg": {
                       "field": 'lnd_712u'
                     }
                   },
                   "lnd_7318u": {
                     "avg": {
                       "field": 'lnd_7318u'
                     }
                   },
                   "lnd_78017w": {
                     "avg": {
                       "field": 'lnd_78017w'
                     }
                   },
                   "lnd7318u": {
                     "avg": {
                       "field": 'lnd7318u'
                     }
                   },
                   "lnd7128c": {
                     "avg": {
                       "field": 'lnd7128c'
                     }
                   }
                 }
               }
             }
    end
  end
end
