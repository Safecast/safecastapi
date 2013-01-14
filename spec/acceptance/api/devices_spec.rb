require 'spec_helper'

feature "/devices API endpoint" do

  before do
    @user = Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
  end
  let(:user) { @user.reload }
  
  scenario "create a device" do
    post('/devices',
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
    
    idCreated = result.include?('id')
    idCreated.should == true
  end
  
  scenario "empty post" do
    post('/devices',
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

feature "/devices with existing devices" do
  
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
  end
  let(:user) { @user.reload }
  let(:first_device) { @first_device.reload }
  let(:second_device) { @second_device.reload }
  let(:third_device) { @third_device.reload }
  
  
  scenario "no duplicate devices" do
    post(
      '/devices',
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
  
  scenario "lookup all devices" do
    result = api_get('/devices', {}, {'HTTP_ACCEPT' => 'application/json'})
    result.length.should == 3
    result.map { |obj| obj['manufacturer'] }.should == ['Safecast', 'Medcom', 'Safecast']
    result.map { |obj| obj['model'] }.should == ['bGeigie', 'Inspector', 'iGeigie']
    result.map { |obj| obj['sensor'] }.should == ['LND-7317', 'LND-712', 'LND-712']
  end
  
  scenario "lookup all Safecast devices" do
    result = api_get('/devices', 
      {
       :where => {:manufacturer => "Safecast"} 
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }
    )
    result.length.should == 2
    result.map { |obj| obj['manufacturer'] }.should == ['Safecast', 'Safecast']
    result.map { |obj| obj['model'] }.should == ['bGeigie', 'iGeigie']
    result.map { |obj| obj['sensor'] }.should == ['LND-7317', 'LND-712']
  end
  
  scenario "lookup a particular device" do
    result = api_get('/devices', 
      {
        :where => {:manufacturer => "Safecast", :model => "iGeigie"}
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
  
end
