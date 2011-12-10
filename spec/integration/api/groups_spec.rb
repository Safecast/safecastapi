require 'spec_helper'

feature "/api/groups API endpoint" do

  before do
    @user = Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
  end
  let(:user) { @user.reload }
  
  scenario "create a measurement group" do
    post('/api/groups.json',{
      :auth_token     => user.authentication_token,
      :description    => "This group contains test measurements",
      :device_mfg     => "Safecast",
      :device_model   => "bGeigie",
      :device_sensor  => "LND-7317"
    })
    result = ActiveSupport::JSON.decode(response.body)
    result['description'].should == 'This group contains test measurements'
    result['device_mfg'].should == 'Safecast'
    result['device_model'].should == 'bGeigie'
    result['device_sensor'].should == 'LND-7317'
    result['user_id'].should == user.id
    
    idCreated = result.include?('group_id')
    idCreated.should == true
  end
  
  scenario "empty post" do
    post('/api/measurements.json',{ :auth_token => user.authentication_token })
    
    result = ActiveSupport::JSON.decode(response.body)
    result['description'].should == ["can't be blank"]
    #mfg, model, and sensor are optional, but description is required
  end
  
  scenario "get my groups" do
    
  end
  
  scenario "create new measurement as a part of a group" do
    post('/api/groups.json',{
      :auth_token     => user.authentication_token,
      :description    => "A test group",
    })
    result = ActiveSupport::JSON.decode(response.body)
    result['description'].should == "A test group"
    
    post("/api/groups/#{result.group_id}/measurements.json", {
      :auth_token     => user.authentication_token,
      :measurement    => {
        :value          => 334,
        :unit           => 'cpm',
        :latitude       => 3.3,
        :longitude      => 4.4
      }
    })
    
  end
  
  scenario "add a measurement to an existing group" do
    
  end
  
end

feature "/api/measurements" do

  let(:user) { Fabricate(:user) }
  let!(:first_measurement) { Fabricate(:measurement, :value => 10) }
  let!(:second_measurement) { Fabricate(:measurement, :value => 12, :user => user) }
  
  scenario "all measurements (/api/measurements)" do
    result = api_get("/api/measurements.json")
    result.length.should == 2
    result.map { |obj| obj['value'] }.should == [10, 12]
  end
  
  scenario "get my measurements (/api/users/X/measurements)" do
    result = api_get("/api/users/#{user.id}/measurements.json")
    result.length.should == 1
    result.first['value'].should == 12
  end
  
end