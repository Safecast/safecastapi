require 'spec_helper'

feature "/users API endpoint" do

  before do
    Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
  end
  
  scenario "lookup user" do
    get('/api/users/finger.json', :email => 'paul@rslw.com')
    result = ActiveSupport::JSON.decode(response.body)
    result['name'].should == 'Paul Campbell'
  end
  
end