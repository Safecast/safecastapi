require 'spec_helper'

feature "/api/devices API endpoint" do

  before do
    @user = Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
  end
  let(:user) { @user.reload }
  
  scenario "create a device" do
    post('/api/devices.json',{
      :auth_token     => user.authentication_token,
      :device         => {
        :mfg     => "Safecast",
        :model   => "bGeigie",
        :sensor  => "LND-7317"
      }
    })
    result = ActiveSupport::JSON.decode(response.body)
    result['mfg'].should == 'Safecast'
    result['model'].should == 'bGeigie'
    result['sensor'].should == 'LND-7317'
    
    idCreated = result.include?('id')
    idCreated.should == true
  end
  
  scenario "empty post" do
    post('/api/devices.json', :auth_token => user.authentication_token)
    
    result = ActiveSupport::JSON.decode(response.body)
    result['mfg'].should == ["can't be blank"]
    result['model'].should == ["can't be blank"]
    result['sensor'].should == ["can't be blank"]
  end
  
end

feature "/api/devices with existing devices" do
  
  before do
    @user = Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
    @first_device = Fabricate(:device, {
      :mfg      => 'Safecast',
      :model    => 'bGeigie',
      :sensor   => 'LND-7317'
    })
    @second_device = Fabricate(:device, {
      :mfg      => 'Medcom',
      :model    => 'Inspector',
      :sensor   => 'LND-712'
    })
    @third_device = Fabricate(:device, {
      :mfg      => 'Safecast',
      :model    => 'iGeigie',
      :sensor   => 'LND-712'
    })
  end
  let(:user) { @user.reload }
  let(:first_device) { @first_device.reload }
  let(:second_device) { @second_device.reload }
  let(:third_device) { @third_device.reload }
  
  
  scenario "no duplicate devices" do
    post('/api/devices.json', {
      :auth_token     => user.authentication_token,
      :device         => {
        :mfg     => "Safecast",
        :model   => "bGeigie",
        :sensor  => "LND-7317"
      }
    })
    result = ActiveSupport::JSON.decode(response.body)
    result['id'].should == first_device.id
  end
  
  scenario "lookup all devices" do
    result = api_get('/api/devices.json')
    result.length.should == 3
    result.map { |obj| obj['mfg'] }.should == ['Safecast', 'Medcom', 'Safecast']
    result.map { |obj| obj['model'] }.should == ['bGeigie', 'Inspector', 'iGeigie']
    result.map { |obj| obj['sensor'] }.should == ['LND-7317', 'LND-712', 'LND-712']
  end
  
  scenario "lookup all Safecast devices" do
    result = api_get('/api/devices.json', :where => {:mfg => "Safecast"})
    result.length.should == 2
    result.map { |obj| obj['mfg'] }.should == ['Safecast', 'Safecast']
    result.map { |obj| obj['model'] }.should == ['bGeigie', 'iGeigie']
    result.map { |obj| obj['sensor'] }.should == ['LND-7317', 'LND-712']
  end
  
  scenario "lookup a particular device" do
    result = api_get('/api/devices.json', :where => {:mfg => "Safecast", :model => "iGeigie"})
    result.length.should == 1
    result.first['mfg'].should == "Safecast"
    result.first['model'].should == "iGeigie"
    result.first['sensor'].should == "LND-712"
  end
  
end