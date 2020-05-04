# frozen_string_literal: true

feature '/devices API endpoint', type: :request do
  before do
    @user = Fabricate(:user, email: 'paul@rslw.com', name: 'Paul Campbell')
  end
  let(:user) { @user.reload }

  scenario 'create a device' do
    post('/devices',
         params: {
           api_key: user.authentication_token,
           device: {
             manufacturer: 'Safecast',
             model: 'bGeigie',
             sensor: 'LND-7317'
           }
         },
         headers: { 'HTTP_ACCEPT' => 'application/json' })
    result = ActiveSupport::JSON.decode(response.body)
    expect(result['manufacturer']).to eq('Safecast')
    expect(result['model']).to eq('bGeigie')
    expect(result['sensor']).to eq('LND-7317')

    id_created = result.include?('id')
    expect(id_created).to eq(true)
  end

  scenario 'empty post' do
    post('/devices',
         params: {
           api_key: user.authentication_token
         },
         headers: { 'HTTP_ACCEPT' => 'application/json' })

    result = ActiveSupport::JSON.decode(response.body)
    expect(result['errors']['manufacturer']).to be_present
    expect(result['errors']['model']).to be_present
    expect(result['errors']['sensor']).to be_present
  end
end

feature '/devices with existing devices', type: :request do
  before do
    @user = Fabricate(:user, email: 'paul@rslw.com', name: 'Paul Campbell')
    @first_device = Fabricate(:device, manufacturer: 'Safecast',
                                       model: 'bGeigie',
                                       sensor: 'LND-7317')
    @second_device = Fabricate(:device, manufacturer: 'Medcom',
                                        model: 'Inspector',
                                        sensor: 'LND-712')
    @third_device = Fabricate(:device, manufacturer: 'Safecast',
                                       model: 'iGeigie',
                                       sensor: 'LND-712')
  end
  let(:user) { @user.reload }
  let(:first_device) { @first_device.reload }
  let(:second_device) { @second_device.reload }
  let(:third_device) { @third_device.reload }

  scenario 'no duplicate devices' do
    post('/devices',
         params: {
           api_key: user.authentication_token,
           device: {
             manufacturer: 'Safecast',
             model: 'bGeigie',
             sensor: 'LND-7317'
           }
         },
         headers: { 'HTTP_ACCEPT' => 'application/json' })
    result = ActiveSupport::JSON.decode(response.body)
    expect(result['id']).to eq(first_device.id)
  end

  scenario 'lookup all devices' do
    result = api_get('/devices', headers: { 'HTTP_ACCEPT' => 'application/json' })
    expect(result.length).to eq(3)
    expect(result.map { |obj| obj['manufacturer'] }).to eq(%w(Safecast Medcom Safecast))
    expect(result.map { |obj| obj['model'] }).to eq(%w(bGeigie Inspector iGeigie))
    expect(result.map { |obj| obj['sensor'] }).to eq(['LND-7317', 'LND-712', 'LND-712'])
  end

  scenario 'lookup all Safecast devices' do
    result = api_get('/devices',
                     params: {
                       manufacturer: 'Safecast'
                     },
                     headers: { 'HTTP_ACCEPT' => 'application/json' })
    expect(result.length).to eq(2)
    expect(result.map { |obj| obj['manufacturer'] }).to eq(%w(Safecast Safecast))
    expect(result.map { |obj| obj['model'] }).to eq(%w(bGeigie iGeigie))
    expect(result.map { |obj| obj['sensor'] }).to eq(['LND-7317', 'LND-712'])
  end

  scenario 'lookup a particular device' do
    result = api_get('/devices',
                     params: {
                       manufacturer: 'Safecast', model: 'iGeigie'
                     },
                     headers: { 'HTTP_ACCEPT' => 'application/json' })
    expect(result.length).to eq(1)
    expect(result.first['manufacturer']).to eq('Safecast')
    expect(result.first['model']).to eq('iGeigie')
    expect(result.first['sensor']).to eq('LND-712')
  end
end
