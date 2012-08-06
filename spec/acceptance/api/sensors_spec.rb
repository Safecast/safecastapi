require 'spec_helper'

feature "/api/sensors API endpoint" do
  before do
    @user = Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
  end
  let(:user) { @user.reload }

  scenario "create a radiation sensor" do

    post('/api/sensors',
      {
        :api_key        => user.authentication_token,
        :sensor => {
          :manufacturer     => "LND",
          :model            => "7317",
          :category         => "radiation",
          :type             => "gamma",
        }
      },
      {
        'HTTP_ACCEPT' => 'application/json'
      }
    )
    result = ActiveSupport::JSON.decode(response.body)
    result['manufacturer'].should == 'LND'
    result['model'].should == '7317'
    result['category'].should == 'radiation'
    result['type'].should == 'gamma'
    
    idCreated = result.include?('id')
    idCreated.should == true
  end

  scenario "create an air sensor" do

  end

end
