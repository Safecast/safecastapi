# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IngestController, type: :controller do
  include ElasticsearchHelpers

  describe 'GET #index' do
    let(:client) { IngestMeasurement.__elasticsearch__.client }

    before do
      put_template_for_ingest_measurements(client)
      [
        {
          device_urn: 'safecast:2651380949',
          pms_pm02_5: 1.0,
          when_captured: '2019-01-25T01:00:00',
          '@timestamp': '2019-01-25T01:00:00Z'
        },
        {
          device_urn: 'safecast:872300871',
          pms_pm02_5: 1.5,
          when_captured: '2019-01-25T01:30:00',
          '@timestamp': '2019-01-25T01:30:00Z'
        },
        {
          device_urn: 'safecast:2651380949',
          pms_pm02_5: 2.0,
          when_captured: '2019-01-25T02:00:00',
          '@timestamp': '2019-01-25T02:00:00Z'
        },
        {
          device_urn: 'safecast:2651380949',
          pms_pm10_0: 2.1,
          when_captured: '2019-01-25T02:00:00',
          '@timestamp': '2019-01-25T02:00:00Z'
        },
        {
          device_urn: 'safecast:2651380949',
          pms_pm02_5: 3.0,
          when_captured: '2019-01-25T03:00:00',
          '@timestamp': '2019-01-25T03:00:00Z'
        }
      ].each do |body|
        client.index(
          index: 'ingest-measurements-2019-01-25',
          type: '_doc',
          body: body
        )
      end
      client.indices.refresh
    end

    after do
      delete_ingest_measurements_indicies(client)
    end

    context 'without parameters' do
      before { get :index }

      it { expect(response).to be_ok }
    end

    context 'When selecting PM 2.5 in Fukushima on 2019-01-25' do
      let(:params) do
        {
          area: 'fukushima',
          field: 'pms_pm02_5',
          uploaded_after: '2019-01-25T00:00:00',
          uploaded_before: '2019-01-25T23:59:59'
        }
      end

      before { get :index, params: params }

      it 'should list 3 data' do
        expect(response).to be_ok
        data = assigns(:data)
        expect(data.size).to eq(3)
      end
    end

    context 'When selecting PM 2.5 in Fukushima between 01:00 and 03:00 on 2019-01-25' do
      let(:params) do
        {
          area: 'fukushima',
          field: 'pms_pm02_5',
          uploaded_after: '2019-01-25T00:00:00',
          uploaded_before: '2019-01-25T02:59:59'
        }
      end

      before { get :index, params: params }

      it 'should list 2 data' do
        expect(response).to be_ok
        data = assigns(:data)
        expect(data.size).to eq(2)
      end
    end

    context 'When selecting PM 10 in Fukushima on 2019-01-25' do
      let(:params) do
        {
          area: 'fukushima',
          field: 'pms_pm10_0',
          uploaded_after: '2019-01-25T00:00:00',
          uploaded_before: '2019-01-25T23:59:59'
        }
      end

      before { get :index, params: params }

      it 'should list 1 datum' do
        expect(response).to be_ok
        data = assigns(:data)
        expect(data.size).to eq(1)
      end
    end

    context 'When selecting PM 2.5 in Southern California on 2019-01-25' do
      let(:params) do
        {
          area: 'southern_california',
          field: 'pms_pm02_5',
          uploaded_after: '2019-01-25T00:00:00',
          uploaded_before: '2019-01-25T23:59:59'
        }
      end

      before { get :index, params: params }

      it 'should list 1 datum' do
        expect(response).to be_ok
        data = assigns(:data)
        expect(data.size).to eq(1)
      end
    end
  end
end
