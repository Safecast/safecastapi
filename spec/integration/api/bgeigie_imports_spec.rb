require 'spec_helper'

feature "/bgeigie_imports API endpoint" do

  before(:each) do
    User.destroy_all
    @user ||= Fabricate(:user,
                      :email => 'paul@rslw.com',
                      :name => 'Paul Campbell')
    
    @result ||= api_post('/bgeigie_imports',{
      :api_key        => @user.authentication_token,
      :bgeigie_import => {
        :source => fixture_file_upload('/bgeigie.log')
      }
    }, {'HTTP_ACCEPT' => 'application/json'})
  end
  
  context "just an upload" do
    scenario "response should be unprocessed" do
      @result['id'].should_not be_blank
      @result['status'].should == 'unprocessed'
      @result['md5sum'].should == 'aad36f9743753b490745c9656cd8fc79'
    end
  end
  
  context "after processing" do

    before(:each) { Delayed::Worker.new.work_off; BgeigieImport.find_each(&:finalize!) }
    let!(:updated_result) do
      api_get(
        "/bgeigie_imports/#{@result['id']}",
        {},
        {'HTTP_ACCEPT' => 'application/json'}
      )
    end
    
    subject { updated_result }

    scenario "response should be processed" do      
      updated_result['status'].should == 'done'
    end
    
    scenario "it should have imported a bunch of measurements" do
      updated_result['measurements_count'].should == 23
    end
  end
end
