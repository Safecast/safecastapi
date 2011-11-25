require 'spec_helper'

feature "/api/measurements API endpoint" do

  before do
    @user = Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
  end
  let(:user) { @user.reload }
  
  scenario "lookup measurements" do
    post('/api/measurements.json',{
      :auth_token => user.authentication_token,
      :measurement => {
        :value => 123
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