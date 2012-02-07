require 'spec_helper'

feature "/api/bgeigie_imports API endpoint" do

  before(:each) do
    User.destroy_all
    @user ||= Fabricate(:user,
                      :email => 'paul@rslw.com',
                      :name => 'Paul Campbell')
    
    @result ||= api_post('/api/bgeigie_imports',{
      :auth_token => @user.authentication_token,
      :bgeigie_import => {
        :source => fixture_file_upload('spec/fixtures/bgeigie.log')
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

    before(:each) { Delayed::Worker.new.work_off }
    let!(:updated_result) do
      api_get(
        "/api/bgeigie_imports/#{@result['id']}",
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
    
    it "should create a map" do
      @user.should have(1).maps
      map = @user.maps.first
      map.name.should == "bGeigie Import"
      map.should have(23).measurements
    end
  end
end
