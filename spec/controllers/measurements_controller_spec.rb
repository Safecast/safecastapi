# frozen_string_literal: true

RSpec.describe MeasurementsController, type: :controller do
  let(:user) { Fabricate(:user) }
  let(:api_key) { user.authentication_token }
  let(:valid_data) do
    {
      captured_at: '2016-06-01T00:00:00+0900',
      device_id: '1',
      unit: 'usv',
      user_id: user.id,
      value: '0.1',
      latitude: '38.6',
      longitude: '-12.4',
      location_name: 'Tokyo',
      height: '1m',
      surface: 'Soil',
      radiation: 'Air'
    }
  end
  let(:existing_measurement) { Fabricate(:measurement, user: user) }

  describe 'GET #index' do
    context 'when only distance is specified in parameter' do
      before do
        get :index, params: { distance: 1 }
      end

      it 'returns HTTP 200 OK' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST #create', format: :json do
    before do
      post :create, params: { api_key: api_key, format: :json }.merge(post_params)
    end

    context 'valid data' do
      let(:post_params) { { measurement: valid_data } }

      it { expect(response.status).to eq(201) }
      it { expect(user.reload.measurements.count).to eq(1) }
      it 'should have values in post data' do
        measurement = user.reload.measurements.first
        expect(measurement.radiation).to eq(valid_data[:radiation])
      end
    end

    context 'empty data' do
      let(:post_params) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(user.reload.measurements.count).to eq(0) }
    end

    context 'duplicated data as created before' do
      let(:post_params) do
        {
          measurement: existing_measurement.attributes.slice(
            *valid_data.keys
          )
        }
      end

      it { expect(response.status).to eq(422) }
      it 'should not create new measurement' do
        expect(user.reload.measurements.count).to eq(1)
      end
    end
  end

  describe 'POST #create', format: :json, from: 'API-Gateway' do
    # https://github.com/Safecast/API-Gateways posts measurement
    # JSON data in this way.
    context 'valid data without measurement prefix' do
      let(:post_params) { valid_data }

      before do
        request.headers['Content-Type'] = 'application/json'

        post :create, params: { api_key: api_key, format: :json }.merge(post_params)
      end

      it { expect(response.status).to eq(201) }
      it { expect(user.reload.measurements.count).to eq(1) }
    end
  end

  describe 'GET #count' do
    before do
      Fabricate(:measurement, user: user, value: '100')
      Fabricate(:measurement, user: user, value: '200')

      get :count, format: count_format
    end

    context 'when html' do
      let(:count_format) { :html }

      # Test can't assert 2 since switching to estimated row count
      it { expect(assigns(:count)).to eq(0) }
    end

    context 'when json' do
      let(:count_format) { :json }

      # Test can't assert 2 since switching to estimated row count
      it { expect(JSON.parse(response.body)).to eq('count' => 0) }
    end
  end

  describe 'GET #new' do
    before do
      sign_in user

      get :new
    end

    context 'when user has no measurement' do
      it { expect(response).to be_ok }
      it 'should use default measurement' do
        measurement = assigns(:measurement)
        expect(measurement.location).to eq(Measurement.default.location)
        expect(measurement.location_name)
          .to eq(Measurement.default.location_name)
      end
    end

    context 'when user has measurement' do
      let!(:last_measurement) { Fabricate(:measurement, user: user) }

      it { expect(response).to be_ok }
      it 'should use last measurement' do
        extract_attributes =
          ->(m) { m.attributes.slice(:value, :location, :location_name) }
        expect(extract_attributes.call(assigns(:measurement)))
          .to eq(extract_attributes.call(last_measurement))
      end
    end
  end
end
