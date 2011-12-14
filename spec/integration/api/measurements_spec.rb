require 'spec_helper'

feature "/api/measurements API endpoint" do

  let!(:user) do
    @user ||= Fabricate(:user,
                      :email => 'paul@rslw.com',
                      :name => 'Paul Campbell')
  end 

  
  scenario "lookup measurements" do
    post('/api/measurements.json',{
      :auth_token => user.authentication_token,
      :measurement => {
        :value      => 123,
        :unit       => 'cpm',
        :latitude   => 1.1,
        :longitude  => 2.2
      }
    })
    result = ActiveSupport::JSON.decode(response.body)
    result['value'].should == 123
    result['user_id'].should == user.id
  end
  
  scenario "empty post" do
    post('/api/measurements.json',{ :auth_token => user.authentication_token })
    
    result = ActiveSupport::JSON.decode(response.body)
    result['value'].should == ["can't be blank"]
  end
end

feature "/api/measurements" do

  let(:user) { Fabricate(:user) }
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
  
end
