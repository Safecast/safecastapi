require "spec_helper"

feature "User submits a reading" do
  let!(:user) { Fabricate(:user) }
  let!(:measurement) { Fabricate(:measurement, :user => user, :value => 10101) }
  
  before { sign_in(user) }

  scenario "First reading" do
    visit("/")
    click_link("My Measurements")
    page.should have_content("10101")
  end
end
