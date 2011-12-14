require 'spec_helper'

feature "/api/bgeigie_imports API endpoint" do

  before do
    
  end
  let!(:user) do
    @user ||= Fabricate(:user,
                      :email => 'paul@rslw.com',
                      :name => 'Paul Campbell')
  end 


  scenario "post an import" do
    result = api_post('/api/bgeigie_imports.json',{
      :auth_token => user.authentication_token,
      :bgeigie_import => {
        :source => fixture_file_upload('/bgeigie.log')
      }
    })

    result['id'].should_not be_blank
  end
end
