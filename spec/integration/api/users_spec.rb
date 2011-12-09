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
    post('/api/users', :email => 'kevin@rkn.la', :name => 'Kevin Nelson', :password => 'testing123')
    result = ActiveSupport::JSON.decode(response.body)
    result['message'].should == 'User created successfully'
  end
  
  scenario "authenticate existing user" do
    get('/api/users/auth.json', :email => 'paul@rslw.com', :password => 'monkeys')
    result = ActiveSupport::JSON.decode(response.body)
    hasAuth = result.include?('auth_token')
    hasAuth.should == true
  end
  
  scenario "authentication fails with invalid password" do
    get('/api/users/auth.json', :email => 'paul@rslw.com', :password => 'monekys')
    result = ActiveSupport::JSON.decode(response.body)
    result['message'].should == "Couldn't sign in"
  end
  
end