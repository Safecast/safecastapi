require "spec_helper"

feature "Guest signs up" do
  context "as a new user" do
    scenario "signing up" do
      sign_up
      page.should have_content("Sign out")
    end
  end
end