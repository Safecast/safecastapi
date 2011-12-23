require 'spec_helper'

feature "/api/users API endpoint" do

  before do
    Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
  end
  
  scenario "lookup user" do
    get('/api/users/finger.json', :email => 'paul@rslw.com')
    result = ActiveSupport::JSON.decode(response.body)
    result['name'].should == 'Paul Campbell'
    result['first_name'].should == 'Paul'
  end
  
  scenario "create user" do
    post('/api/users.json', {
      :email => 'kevin@rkn.la',
      :name => 'Kevin Nelson',
      :password => 'testing123'
    })
    result = ActiveSupport::JSON.decode(response.body)
    result['email'].should == 'kevin@rkn.la'
    result['id'].should_not == nil
    hasAuth = result.include?('authentication_token')
    hasAuth.should == true
  end
  
end