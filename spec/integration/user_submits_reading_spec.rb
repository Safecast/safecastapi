require 'spec_helper'

feature "User Submits Reading" do
  
  before { sign_in_user('paul@rslw.com') }
  let(:user) { User.find_by_email('paul@rslw.com') }
  
  scenario "First Reading", :js => true do
    page.execute_script("document.location.href = '/my/submissions/new'")
    fill_in('Radiation Level', :with => '123')
    fill_in('Location',        :with => '123, 123')
    click_button('Submit')
    click_button('Confirm')
    page.should have_content('Thanks for your submission')
    user.should have(1).measurements
    user.measurements.first.value.should == 123
  end
  
end