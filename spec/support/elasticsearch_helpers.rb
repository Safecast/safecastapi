# frozen_string_literal: true

module ElasticsearchHelpers
  def put_template_for_ingest_measurements(client) # rubocop:disable Metrics/MethodLength
    client.indices.put_template(
      name: 'ingest-measurements',
      body: {
        template: 'ingest-measurements-*',
        order: 0,
        settings: {
          number_of_shards: 1,
          number_of_replicas: 0
        },
        mappings: {
          _default_: {
            _all: {
              norms: false
            },
            _meta: {
              version: '1.0.0'
            },
            date_detection: false,
            dynamic_templates: [
              {
                strings_as_keyword: {
                  mapping: {
                    ignore_above: 1024,
                    type: 'keyword'
                  },
                  match_mapping_type: 'string'
                }
              }
            ],
            properties: {
              :@timestamp => {
                type: 'date'
              },
              service_uploaded: {
                type: 'date'
              },
              :'ingest.location' => {
                type: 'geo_point',
                ignore_malformed: true
              },
              pms_std01_0: {
                type: 'float'
              }
            }
          }
        }
      }
    )
  end

  def delete_ingest_measurements_indicies(client)
    client.indices.delete(index: 'ingest-measurements-*')
  end

  def add_index_to_ingest_measurements(client, body)
    client.index(
      index: 'ingest-measurements-2018-12-01',
      type: 'measurement',
      body: body.merge('@timestamp': '2018-12-01T12:34:56Z')
    )
    client.indices.flush
  end
end
