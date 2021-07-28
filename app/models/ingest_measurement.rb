# frozen_string_literal: true

class IngestMeasurement # rubocop:disable Metrics/ClassLength
  extend ActiveModel::Naming
  include Elasticsearch::Model

  index_name 'ingest-measurements-*'
  document_type '_doc'

  class << self
    def data_for(query)
      search(query: query).results.map(&:_source)
    end

    def query_sensor_data(device_urn) # rubocop:disable Metrics/MethodLength
      search query:
                 { bool: {
                   filter: [
                     {
                       range: {
                         "@timestamp": {
                           gte: 'now-8w',
                           lte: 'now'
                         }
                       }
                     },
                     {
                       term: {
                         device_urn: device_urn
                       }
                     }
                   ]
                 } },
             aggs: {
               sensor_data: {
                 date_histogram: {
                   fixed_interval: '12h',
                   field: '@timestamp',
                   min_doc_count: 0,
                   extended_bounds: {
                     min: 'now-8w',
                     max: 'now'
                   },
                   format: 'yyyy-MM-dd HH'
                 },
                 aggs: {
                   lnd_7128ec: {
                     avg: {
                       field: 'lnd_7128ec'
                     }
                   },
                   lnd_7318c: {
                     avg: {
                       field: 'lnd_7318c'
                     }
                   },
                   lnd_712u: {
                     avg: {
                       field: 'lnd_712u'
                     }
                   },
                   lnd_7318u: {
                     avg: {
                       field: 'lnd_7318u'
                     }
                   },
                   lnd_78017w: {
                     avg: {
                       field: 'lnd_78017w'
                     }
                   },
                   lnd7318u: {
                     avg: {
                       field: 'lnd7318u'
                     }
                   },
                   lnd7128c: {
                     avg: {
                       field: 'lnd7128c'
                     }
                   },
                   lnd_7128ec_mrem: {
                     avg: {
                       field: 'lnd_7128ec',
                       script: {
                         source: '_value/3340'
                       }
                     }
                   },
                   lnd_7318c_mrem: {
                     avg: {
                       field: 'lnd_7318c',
                       script: {
                         source: '_value/3340'
                       }
                     }
                   },
                   lnd_712u_mrem: {
                     avg: {
                       field: 'lnd_712u',
                       script: {
                         source: '_value/3340'
                       }
                     }
                   },
                   lnd_7318u_mrem: {
                     avg: {
                       field: 'lnd_7318u',
                       script: {
                         source: '_value/3340'
                       }
                     }
                   },
                   lnd_78017w_mrem: {
                     avg: {
                       field: 'lnd_78017w',
                       script: {
                         source: '_value/3340'
                       }
                     }
                   },
                   lnd7318u_mrem: {
                     avg: {
                       field: 'lnd7318u',
                       script: {
                         source: '_value/3340'
                       }
                     }
                   },
                   lnd7128c_mrem: {
                     avg: {
                       field: 'lnd7128c',
                       script: {
                         source: '_value/3340'
                       }
                     }
                   },
                   pms_pm10_0: { # rubocop:disable Naming/VariableNumber
                     avg: {
                       field: 'pms_pm10_0'
                     }
                   },
                   pms_pm02_5: { # rubocop:disable Naming/VariableNumber
                     avg: {
                       field: 'pms_pm02_5'
                     }
                   },
                   pms_pm01_0: { # rubocop:disable Naming/VariableNumber
                     avg: {
                       field: 'pms_pm01_0'
                     }
                   },
                   bat_voltage: {
                     avg: {
                       field: 'bat_voltage'
                     }
                   },
                   temperature_C: {
                     avg: {
                       field: 'env_temp'
                     }
                   },
                   humidity: {
                     avg: {
                       field: 'env_humid'
                     }
                   },
                   pressure: {
                     avg: {
                       field: 'env_press'
                     }
                   },
                   temperature_F: {
                     avg: {
                       field: 'env_temp',
                       script: {
                         source: '_value*9/5+32'
                       }
                     }
                   },
                   charging: {
                     avg: {
                       field: 'bat_charging'
                     }
                   },
                   bat_charge: {
                     avg: {
                       field: 'bat_charge'
                     }
                   }
                 }
               }
             }
    end

    def query_last_sensor_location(device_urn)
      search query: { match: { device_urn: device_urn } }, size: 1, sort: [{ "@timestamp": { order: 'desc' } }]
    end
  end
end
