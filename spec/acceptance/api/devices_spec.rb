require 'spec_helper'

feature "/api/devices API endpoint" do

  before do
    @user = Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
  end
  let(:user) { @user.reload }
  
  scenario "create a device with a serial number" do
    post('/api/devices',
      {
        :api_key        => user.authentication_token,
        :device         => {
          :manufacturer     => "Safecast",
          :model            => "bGeigie",
          :sensor           => "LND-7317",
          :serial_number    => "SFCT-001"
        }
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }
    )
    result = ActiveSupport::JSON.decode(response.body)
    result['manufacturer'].should == 'Safecast'
    result['model'].should == 'bGeigie'
    result['sensor'].should == 'LND-7317'
    result['serial_number'].should == 'SFCT-001'
    
    idCreated = result.include?('id')
    idCreated.should == true
  end
  
  scenario "create a device without a serial number" do
    post('/api/devices',
      {
        :api_key        => user.authentication_token,
        :device         => {
          :manufacturer     => "Safecast",
          :model            => "bGeigie",
          :sensor           => "LND-7317"
        }
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }
    )
    result = ActiveSupport::JSON.decode(response.body)
    result['manufacturer'].should == 'Safecast'
    result['model'].should == 'bGeigie'
    result['sensor'].should == 'LND-7317'
    result['serial_number'].should == nil
    
    idCreated = result.include?('id')
    idCreated.should == true
  end
  
  scenario "empty post" do
    post('/api/devices',
      {
        :api_key => user.authentication_token
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }
    )
    
    result = ActiveSupport::JSON.decode(response.body)
    result['errors']['manufacturer'].should be_present
    result['errors']['model'].should be_present
    result['errors']['sensor'].should be_present
  end
  
end

feature "/api/devices with existing devices" do
  
  before do
    @user = Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
    @first_device = Fabricate(:device, {
      :manufacturer     => 'Safecast',
      :model            => 'bGeigie',
      :sensor           => 'LND-7317'
    })
    @second_device = Fabricate(:device, {
      :manufacturer     => 'Medcom',
      :model            => 'Inspector',
      :sensor           => 'LND-712'
    })
    @third_device = Fabricate(:device, {
      :manufacturer     => 'Safecast',
      :model            => 'iGeigie',
      :sensor           => 'LND-712'
    })
    @fourth_device = Fabricate(:device, {
      :manufacturer     => 'Safecast',
      :model            => 'bGeigie',
      :sensor           => 'LND-7317',
      :serial_number    => 'SFCT-BG-001'
    })
  end
  let(:user) { @user.reload }
  let(:first_device) { @first_device.reload }
  let(:second_device) { @second_device.reload }
  let(:third_device) { @third_device.reload }
  let(:fourth_device) { @fourth_device.reload }
  
  
  scenario "no duplicate devices" do
    post(
      '/api/devices',
      {
        :api_key => user.authentication_token,
        :device         => {
          :manufacturer     => "Safecast",
          :model            => "bGeigie",
          :sensor           => "LND-7317"
        }
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }  
    )
    result = ActiveSupport::JSON.decode(response.body)
    result['id'].should == first_device.id
  end

  scenario "unique serial number is not a duplicate device" do
    post(
      '/api/devices',
      {
        :api_key => user.authentication_token,
        :device         => {
          :manufacturer     => "Safecast",
          :model            => "bGeigie",
          :sensor           => "LND-7317",
          :serial_number    => "SFCT-BG-002"
        }
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }  
    )
    result = ActiveSupport::JSON.decode(response.body)
    result['id'].should_not == first_device.id
    result['id'].should_not == fourth_device.id
  end


  scenario "lookup all devices" do
    result = api_get('/api/devices', {}, {'HTTP_ACCEPT' => 'application/json'})
    result.length.should == 4
    result.map { |obj| obj['manufacturer'] }.should == ['Safecast', 'Medcom', 'Safecast', 'Safecast']
    result.map { |obj| obj['model'] }.should == ['bGeigie', 'Inspector', 'iGeigie', 'bGeigie']
    result.map { |obj| obj['sensor'] }.should == ['LND-7317', 'LND-712', 'LND-712', 'LND-7317']
    result.map { |obj| obj['serial_number'] }.should == [nil, nil, nil, 'SFCT-BG-001']
  end
  
  scenario "lookup all Safecast devices" do
    result = api_get('/api/devices', 
      {
       :manufacturer => "Safecast"
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }
    )
    result.length.should == 3
    result.map { |obj| obj['manufacturer'] }.should == ['Safecast', 'Safecast', 'Safecast']
    result.map { |obj| obj['model'] }.should == ['bGeigie', 'iGeigie', 'bGeigie']
    result.map { |obj| obj['sensor'] }.should == ['LND-7317', 'LND-712', 'LND-7317']
    result.map { |obj| obj['serial_number'] }.should == [nil, nil, 'SFCT-BG-001']
  end
  
  scenario "lookup by manufacturer and model" do
    result = api_get('/api/devices', 
      {
        :manufacturer => 'Safecast',
        :model        => 'iGeigie'
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }
    )
    result.length.should == 1
    result.first['manufacturer'].should == "Safecast"
    result.first['model'].should == "iGeigie"
    result.first['sensor'].should == "LND-712"
  end

  scenario "lookup by manufacturer and model with multiple serial numbers" do
    result = api_get('/api/devices', 
      {
        :manufacturer => 'Safecast',
        :model        => 'bGeigie'
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }
    )
    result.length.should == 2
    result.map { |obj| obj['manufacturer'] }.should == ['Safecast', 'Safecast']
    result.map { |obj| obj['model'] }.should == ['bGeigie', 'bGeigie']
    result.map { |obj| obj['sensor'] }.should == ['LND-7317', 'LND-7317']
    result.map { |obj| obj['serial_number'] }.should == [nil, 'SFCT-BG-001']
  end

  scenario "lookup by serial number" do
    result = api_get('/api/devices', 
      {
        :serial_number => 'SFCT-BG-001'
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }
    )
    result.class.should == Hash
    result['manufacturer'].should == 'Safecast'
    result['model'].should == 'bGeigie'
    result['sensor'].should == 'LND-7317'
    result['serial_number'].should == 'SFCT-BG-001'
  end


  
end
