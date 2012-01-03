require 'spec_helper'

feature "/api/measurements API endpoint" do

  let!(:user) do
    User.first || Fabricate(:user,
                      :email => 'paul@rslw.com',
                      :name => 'Paul Campbell')
  end

  scenario "post a new measurement" do
    result = api_post('/api/measurements.json',{
      :auth_token => user.authentication_token,
      :measurement => {
        :value      => 123,
        :unit       => 'cpm',
        :latitude   => 1.1,
        :longitude  => 2.2
      }
    })
    result['value'].should == 123
    result['user_id'].should == user.id
  end
  
  scenario "empty post" do
    result = api_post('/api/measurements.json',{ :auth_token => user.authentication_token })
    result['errors']['value'].should == ["can't be blank"]
  end
end

feature "/api/measurements" do
  
  before(:all) { Measurement.destroy_all }

  let!(:user) { User.first || Fabricate(:user) }
  let!(:first_measurement) { Fabricate(:measurement, :value => 10) }
  let!(:second_measurement) do 
    Fabricate(:measurement, :value => 12, :user_id => user.id)
  end
  
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
  
  scenario "updating is non-destructive" do
    put("/api/measurements/#{second_measurement.id}.json", {
      :auth_token => user.authentication_token,
      :measurement => {
        :value => 15
      }
    })
    
    result = ActiveSupport::JSON.decode(response.body)
    
    result['value'].should == 15
    result['original_id'].should == second_measurement.id

    
    #the above is pretty normal, now we do some gets to check that it was non-destructive
    result = api_get("/api/measurements/#{second_measurement.id}.json", :withHistory => true)
    result.length.should == 2
    result.sort_by! { |obj| obj['value']}
    result.map { |obj| obj['value'] }.should == [12, 15]
    
    
    #withHistory defaults to false, returns latest value
    result = api_get("/api/measurements/#{second_measurement.id}.json")
    result['value'].should == 15
  end
  
end
