require "spec_helper"

feature "Guest signs up" do
  context "as a new user" do
    scenario "signing up" do
      sign_up
      new_user = User.last
      new_user.confirmed_at = Time.now
      new_user.save
      new_user.password = "mynewpassword"
      sign_in(new_user)
      page.should have_content("Sign out")
    end
  end
end
