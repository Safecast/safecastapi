require 'spec_helper'

feature "User Submits Reading" do
  
  before { sign_in_user }
  
  scenario "First Reading", :js => true do
    click_link('Submit')
    fill_in('Radiation Level', :with => '123')
    fill_in('Location',        :with => '123, 123')
    click_button('Submit')
  end
  
end