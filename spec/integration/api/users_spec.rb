require 'spec_helper'

feature "/api/users API endpoint" do

  before(:all) { User.destroy_all }
  before do
    Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
  end
  
  scenario "create user" do
    post('/users.json', :user => {
      :email => 'kevin@rkn.la',
      :name => 'Kevin Nelson',
      :password => 'testing123'
    })
    result = ActiveSupport::JSON.decode(response.body)
    expect(result['email']).to eq('kevin@rkn.la')
    expect(result['id']).not_to eq(nil)
    hasAuth = result.include?('authentication_token')
    expect(hasAuth).to eq(true)
  end
  
end