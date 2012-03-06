require 'spec_helper'

feature "/api/maps API endpoint" do

  before do
    @user = Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
  end
  let(:user) { @user.reload }
  
  scenario "create a measurement map" do
    post('/api/maps.json',{
      :auth_token     => user.authentication_token,
      :map          => {
        :description    => "This map contains test measurements",
        :device         => {
          :manufacturer     => "Safecast",
          :model            => "bGeigie",
          :sensor           => "LND-7317"
        }
      }
    })
    result = ActiveSupport::JSON.decode(response.body)
    
    d = api_get('/api/devices.json', {
      :device => {
        :manufacturer     => "Safecast",
        :model            => "bGeigie",
        :sensor           => "LND-7317"
      }
    })
    result['description'].should == 'This map contains test measurements'
    result['device_id'].should == d.first['id']
    result['user_id'].should == user.id
    
    idCreated = result.include?('id')
    idCreated.should == true
  end
  
  scenario "empty post" do
    post('/api/maps.json',{ :auth_token => user.authentication_token })
    
    result = ActiveSupport::JSON.decode(response.body)
    result['errors']['description'].should == ["can't be blank"]
    #manufacturer, model, and sensor are optional, but description is required
  end
  
end

feature "/api/maps with existing resources" do

  let(:user) { Fabricate(:user) }
  let!(:a_map) { Fabricate(:map, :description => "A test map")}
  let!(:b_map) { Fabricate(:map, :description => "Another test map", :user_id => user.id)}
  let!(:a_measurement) { Fabricate(:measurement, :value => 66, :user_id => user.id) }
  
  scenario "all maps (/api/maps)" do
    result = api_get("/api/maps.json")
    result.length.should == 2
    result.map { |obj| obj['description'] }.should == ['A test map', 'Another test map']
  end
  
  scenario "get my maps (/api/users/X/maps)" do
    result = api_get("/api/users/#{user.id}/maps.json")
    result.length.should == 1
    result.first['description'].should == 'Another test map'
  end
  
  scenario "create new measurement as a part of a map" do
    result = api_get("/api/users/#{user.id}/maps.json")
    map = result.first
    map_id = map['id']
    
    post("/api/maps/#{map_id}/measurements.json", {
      :auth_token     => user.authentication_token,
      :measurement    => {
        :value          => 334,
        :unit           => 'cpm',
        :latitude       => 3.3,
        :longitude      => 4.4
      }
    })
    measurement = ActiveSupport::JSON.decode(response.body)
    measurement['value'].should == 334
    measurement['user_id'].should == user.id
    
    map_measurements = api_get("/api/maps/#{map_id}/measurements.json")
    presence = map_measurements.include?(measurement)   #might need to be tweaked to be proper
    presence.should == true
  end
  
  scenario "add an existing measurement to a map" do
    result = api_get("/api/users/#{user.id}/maps.json")
    map = result.first
    map_id = map['id']
    
    result = api_get("/api/measurements.json")
    measurement = result.first
    measurement_id = measurement['id']
    post("/api/maps/#{map_id}/measurements/#{measurement_id}/add.json", {
      :auth_token     => user.authentication_token
    })
    result = ActiveSupport::JSON.decode(response.body)
    result['value'].should == measurement['value']
    
    map_measurements = api_get("/api/maps/#{map_id}/measurements.json")
    presence = map_measurements.include?(measurement)   #might need to be tweaked to be proper
    presence.should == true
    
  end
  
end
