require 'spec_helper'

feature "/air_imports API endpoint" do

  before(:each) do
    User.destroy_all
    @user ||= Fabricate(:user)
    @result ||= api_post('/air_imports',{
                                               :api_key        => @user.authentication_token,
                                               :air_import => {
                                                   :source => fixture_file_upload('/air0.log')
                                               }
                                           }, {'HTTP_ACCEPT' => 'application/json'})
  end

  context "just an upload" do
    scenario "response should be unprocessed" do
      @result['id'].should_not be_blank
      @result['status'].should == 'unprocessed'
      @result['md5sum'].should == '689ef3703d403ba8c2f42669c313d977'
    end
  end
end
