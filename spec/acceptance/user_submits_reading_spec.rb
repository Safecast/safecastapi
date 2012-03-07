require 'spec_helper'

feature "User Submits Reading" do
  
  before { sign_in_user('paul@rslw.com') }
  let(:user) { User.find_by_email('paul@rslw.com') }
  let(:measurement) { user.measurements.last }
  
  scenario "First Reading" do
    visit('/')
    click_link('Submit')
    fill_in('Radiation Level', :with => '123')
    fill_in('Location',        :with => 'Colwyn Bay, Wales')
    click_button('Submit')
    page.should have_content('123 cpm')
    user.should have(1).measurements
    measurement.value.should == 123
    measurement.location_name.should == 'Colwyn Bay, Wales'
  end
  
end
