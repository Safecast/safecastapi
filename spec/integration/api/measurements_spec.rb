# frozen_string_literal: true

feature '/measurements API endpoint', type: :request do
  let!(:user) do
    User.first || Fabricate(:user,
                            email: 'paul@rslw.com',
                            name: 'Paul Campbell')
  end

  scenario 'post a new measurement' do
    result = api_post('/measurements.json', params: { api_key: user.authentication_token,
                                                      measurement: {
                                                        value: 123,
                                                        unit: 'cpm',
                                                        latitude: 1.1,
                                                        longitude: 2.2
                                                      } })
    expect(result['value']).to eq(123)
    expect(result['user_id']).to eq(user.id)
  end

  scenario 'empty post' do
    result = api_post('/measurements.json', params: { api_key: user.authentication_token })
    expect(result['errors']['value']).to be_present
  end
end

feature '/measurements', type: :request do
  before(:all) { Measurement.destroy_all }

  let!(:user) { User.first || Fabricate(:user) }
  let!(:first_measurement) { Fabricate(:measurement, value: 10) }
  let!(:second_measurement) do
    Fabricate(:measurement, value: 12, user: user)
  end

  scenario 'all measurements (/measurements)' do
    result = api_get('/measurements.json')
    expect(result.length).to eq(2)
    expect(result.map { |obj| obj['value'] }).to eq([10, 12])
  end

  scenario 'get measurement count (/measurements/count)' do
    result = api_get('/measurements/count.json')
    expect(result.length).to eq(1)
    expect(result['count']).to eq(2)
  end

  scenario 'get my measurements (/users/X/measurements)' do
    result = api_get("/measurements.json?user_id=#{user.id}")
    expect(result.length).to eq(1)
    expect(result.first['value']).to eq(12)
  end

  scenario 'updating is non-destructive' do
    put("/measurements/#{second_measurement.id}.json", params: { api_key: user.authentication_token,
                                                                 measurement: {
                                                                   value: 15
                                                                 } })

    result = ActiveSupport::JSON.decode(response.body)

    expect(result['value']).to eq(15)
    expect(result['original_id']).to eq(second_measurement.id)

    # the above is pretty normal, now we do some gets to check that it was non-destructive
    result = api_get("/measurements.json?original_id=#{second_measurement.id}")
    expect(result.length).to eq(2)
    result.sort_by! { |obj| obj['value'] }
    expect(result.map { |obj| obj['value'] }).to eq([12, 15])

    # withHistory defaults to false, returns latest value
    result = api_get("/measurements/#{second_measurement.id}.json")
    expect(result['value']).to eq(12)
  end

  scenario 'get new measurements since some time' do
    sleep 1
    cutoff_time = DateTime.now
    sleep 3

    api_post('/measurements.json', params: { api_key: user.authentication_token,
                                             measurement: {
                                               value: 4342,
                                               unit: 'cpm',
                                               latitude: 76.667,
                                               longitude: 33.321
                                             } })
    result = api_get('/measurements.json', params: { since: cutoff_time })

    expect(result.length).to eq(1)
    expect(result.first['value']).to eq(4342)
    expect(result.first['latitude']).to eq(76.667)
    expect(result.first['longitude']).to eq(33.321)
  end
end
