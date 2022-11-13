# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IngestMeasurement do
  include ElasticsearchHelpers

  describe '#data_for_device' do
    before do
      put_template_for_ingest_measurements(described_class.__elasticsearch__.client)
      [
        { device_urn: 'safecast:374304606', device: '374304606' },
        { device_urn: 'safecast:474304605', device: '474304605' }
      ].each do |params|
        add_index_to_ingest_measurements(described_class.__elasticsearch__.client, params)
      end
    end

    after { delete_ingest_measurements_indicies(described_class.__elasticsearch__.client) }

    it 'should fetch data' do
      query = {
        terms: {
          device_urn: ['safecast:374304606', 'safecast:474304605']
        }
      }
      data = described_class.data_for(query)
      expect(data)
        .to contain_exactly(
          have_attributes(device: '374304606'),
          have_attributes(device: '474304605')
        )

      query = {
        bool: {
          must: [
            terms: { device_urn: ['safecast:374304606', 'safecast:474304605'] }
          ],
          filter: { match: { device_urn: 'safecast:474304605' } }
        }
      }
      data = described_class.data_for(query)
      expect(data)
        .to contain_exactly(have_attributes(device: '474304605'))
    end
  end
end
