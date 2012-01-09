require 'spec_helper'

feature "User Profile" do
  
  scenario "Viewing User Profile" do
    user = sign_in_user
    click_link('Profile')
    page.should have_content(user.authentication_token)
  end
  
end