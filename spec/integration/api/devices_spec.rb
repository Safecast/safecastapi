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
    @device = Fabricate(:device, :mfg => 'Safecast', :model => 'bGeigie', :sensor => 'LND-7317')
  end
  let(:user) { @user.reload }
  let(:device) { @device.reload }
  
  
end