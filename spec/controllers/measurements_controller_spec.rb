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
      location_name: 'Tokyo'
    }
  end
  let(:existing_measurement) { Fabricate(:measurement, user: user) }

  describe 'POST #create', format: :json do
    before do
      post :create, { api_key: api_key, format: :json }.merge(post_params)
    end

    context 'valid data' do
      let(:post_params) { { measurement: valid_data } }

      it { expect(response.status).to eq(201) }
      it { expect(user.reload.measurements.count).to eq(1) }
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
end
