require "spec_helper"

feature "User Profile" do
  let(:user) { Fabricate(:user) }
  before { sign_in(user) }

  scenario "viewing a user profile" do
    click_link("Profile")
    page.should have_content(user.authentication_token)
  end
end