require 'spec_helper'

feature "/measurements API endpoint" do

  let!(:user) do
    User.first || Fabricate(:user,
                      :email => 'paul@rslw.com',
                      :name => 'Paul Campbell')
  end

  scenario "post a new measurement" do
    result = api_post('/measurements.json',{
      :api_key => user.authentication_token,
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
    result = api_post('/measurements.json',{ :api_key => user.authentication_token })
    result['errors']['value'].should be_present
  end
end

feature "/measurements" do
  
  before(:all) { Measurement.destroy_all }

  let!(:user) { User.first || Fabricate(:user) }
  let!(:first_measurement) { Fabricate(:measurement, :value => 10) }
  let!(:second_measurement) do 
    Fabricate(:measurement, :value => 12, :user => user)
  end
  
  scenario "all measurements (/measurements)" do
    result = api_get("/measurements.json")
    result.length.should == 2
    result.map { |obj| obj['value'] }.should == [10, 12]
  end

  scenario "get measurement count (/measurements/count)" do
    result = api_get('/measurements/count.json')
    result.length.should == 1
    result['count'].should == 2
  end
  
  scenario "get my measurements (/users/X/measurements)" do
    result = api_get("/measurements.json?user_id=#{user.id}")
    result.length.should == 1
    result.first['value'].should == 12
  end
  
  scenario "updating is non-destructive" do
    put("/measurements/#{second_measurement.id}.json", {
      :api_key => user.authentication_token,
      :measurement => {
        :value => 15
      }
    })
    
    result = ActiveSupport::JSON.decode(response.body)
    
    result['value'].should == 15
    result['original_id'].should == second_measurement.id

    
    #the above is pretty normal, now we do some gets to check that it was non-destructive
    result = api_get("/measurements/#{second_measurement.id}.json", :withHistory => true)
    result.length.should == 2
    result.sort_by! { |obj| obj['value']}
    result.map { |obj| obj['value'] }.should == [12, 15]
    
    
    #withHistory defaults to false, returns latest value
    result = api_get("/measurements/#{second_measurement.id}.json")
    result['value'].should == 15
  end

  scenario "get new measurements since some time" do
    sleep 1
    cutoff_time = DateTime.now
    sleep 3 

    new_measurement = api_post('/measurements.json',{
      :api_key => user.authentication_token,
      :measurement => {
        :value      => 4342,
        :unit       => 'cpm',
        :latitude   => 76.667,
        :longitude  => 33.321
      }
    })
    result = api_get('/measurements.json', {
      :since => cutoff_time
    })

    result.length.should == 1
    result.first['value'].should == 4342
    result.first['latitude'].should == 76.667
    result.first['longitude'].should == 33.321
  end
  
end
