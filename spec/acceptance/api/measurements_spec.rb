require 'spec_helper'

feature "/api/measurements API endpoint" do

  let!(:user) do
    User.first || Fabricate(:user,
                      :email => 'paul@rslw.com',
                      :name => 'Paul Campbell')
  end

  let!(:device) { Device.first || Fabricate(:device) }

  scenario "post a new measurement" do
    result = api_post('/api/measurements.json',{
      :api_key => user.authentication_token,
      :measurement => {
        :value      => 123,
        :unit       => 'cpm',
        :latitude   => 1.1,
        :longitude  => 2.2,
        :device_id  => device.id,
        :sensor_id  => device.sensors.first.id
      }
    })
    result['value'].should == 123
    result['user_id'].should == user.id
  end
  
  scenario "empty post" do
    result = api_post('/api/measurements.json',{ :api_key => user.authentication_token })
    result['errors']['value'].should be_present
  end

  scenario "post a measurement without a device or sensor" do
    result = api_post('/api/measurements.json',{
      :api_key => user.authentication_token,
      :measurement => {
        :value      => 31.2,
        :unit       => 'cpm',
        :latitude   => 21.03,
        :longitude  => -15.5,
      }
    })
    result['value'].should == 31.2
    result['user_id'].should == user.id
    # if this endpoint doesn't work, result is nil, so the test breaks.
  end
end

feature "/api/measurements" do
  
  before(:all) { Measurement.destroy_all }

  let!(:user) { User.first || Fabricate(:user) }
  let!(:device) { Device.first || Fabricate(:device) }
  let!(:first_measurement) do 
    Fabricate(:measurement,
              :value => 10,
              :unit => 'cpm',
              :latitude => 22.3,
              :longitude => 24.5,
              :device => device,
              :sensor => device.sensors.first)
  end
  let!(:second_measurement) do 
    Fabricate(:measurement,
              :user => user,
              :value => 12,
              :unit => 'cpm',
              :latitude => 22.3,
              :longitude => 24.5,
              :device => device,
              :sensor => device.sensors.first)
  end
  
  scenario "all measurements (/api/measurements)" do
    result = api_get("/api/measurements.json")
    result.length.should == 2
    result.sort_by! { |obj| obj['value']}
    result.map { |obj| obj['value'] }.should == [10, 12]
    
  end

  scenario "get measurement count (/api/measurements/count)" do
    result = api_get('api/measurements/count.json')
    result.length.should == 1
    result['count'].should == 2
  end
  
  scenario "get my measurements (/api/users/X/measurements)" do
    result = api_get("/api/users/#{user.id}/measurements.json")
    result.length.should == 1
    result.first['value'].should == 12
  end
  
  scenario "updating is non-destructive" do
    put("/api/measurements/#{second_measurement.id}.json", {
      :api_key => user.authentication_token,
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

  scenario "get new measurements since some time" do
    sleep 1
    cutoff_time = DateTime.now
    sleep 3 

    new_measurement = api_post('/api/measurements.json',{
      :api_key => user.authentication_token,
      :measurement => {
        :value      => 4342,
        :unit       => 'cpm',
        :latitude   => 76.667,
        :longitude  => 33.321,
        :device_id  => device.id,
        :sensor_id  => device.sensors.first.id
      }
    })
    result = api_get('api/measurements.json', {
      :since => cutoff_time
    })

    Measurement.count.should == 3 # make sure that the let! measurements are happening
    result.length.should == 1
    result.first['value'].should == 4342
    result.first['latitude'].should == 76.667
    result.first['longitude'].should == 33.321
  end

  scenario 'distinguish between radiation and air measurements' do
    air_sensor = Sensor.create(
      :manufacturer => 'Some Company',
      :model        => 'Best fucking air sensor ever',
      :measurement_type => 'all the things',
      :measurement_category => 'air'
    )
    air_device = Device.create(
      :manufacturer => 'Steven Wright',
      :model        => 'HackSense', # well, I needed to call it something, right?
      :sensors      => [air_sensor]
    )

    air_measurement = Measurement.create(
      :value      => 37,
      :unit       => 'ppm',
      :latitude   => 87.7,
      :longitude  => -66.5,
      :device_id  => air_device.id,
      :sensor_id  => air_sensor.id
    )

    result = api_get('/api/measurements.json', {
      :category => 'air'
    })

    result.length.should == 1

    result.first['value'].should == 37
    result.first['unit'].should == 'ppm'


    result = api_get('/api/measurements.json', {
      :category => 'radiation'
    })

    result.length.should == 2
    values = result.map { |obj| obj['value'] }
    values.should include 10
    values.should include 12
    values.should_not include 37


    # default to radiation if no type is specified
    # this is a backwards compatibility hack for now, and should probably be removed in the future.
    result = api_get('/api/measurements.json')
    result.length.should == 2
    result.sort_by! { |obj| obj['value']}
    result.map { |obj| obj['value'] }.should == [10, 12]

  end

end

