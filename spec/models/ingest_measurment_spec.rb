# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IngestMeasurement, type: :model do
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
      data = described_class.data_for(device_urn: ['safecast:374304606', 'safecast:474304605'])
      expect(data).to contain_exactly(have_attributes(device: '374304606'), have_attributes(device: '474304605'))
    end
  end
end
