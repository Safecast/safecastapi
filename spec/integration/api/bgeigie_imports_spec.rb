require 'spec_helper'

feature "/api/bgeigie_imports API endpoint" do

  let!(:user) do
    @user ||= Fabricate(:user,
                      :email => 'paul@rslw.com',
                      :name => 'Paul Campbell')
  end 

  let!(:result) do
    @result ||= api_post('/api/bgeigie_imports.json',{
      :auth_token => user.authentication_token,
      :bgeigie_import => {
        :source => fixture_file_upload('/bgeigie.log')
      }
    })
  end
  
  context "just an uplaod" do
    scenario "response should be unprocessed" do
      result['id'].should_not be_blank
      result['status'].should == 'unprocessed'
      result['md5sum'].should == 'aad36f9743753b490745c9656cd8fc79'
    end
  end
  
  context "after processing" do
    before { Delayed::Worker.new.work_off }
    scenario "response should be processed" do
      updated_result = api_get("/api/bgeigie_imports/#{result['id']}.json")
      updated_result['status'].should == 'done'
    end
  end
  
end
