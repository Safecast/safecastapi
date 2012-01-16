require 'spec_helper'

feature "User uploads bgeigie log" do
  
  before { sign_in_user('paul@rslw.com') }
  let(:user) { User.find_by_email('paul@rslw.com') }
  
  scenario "Uploading a bgeigie log file" do
    visit('/')
    click_link('Measurements')
    click_link('Upload bGeigie log file')
    attach_file("File", path)
    click_button("Submit")
    Delayed::Worker.new.work_off 
    click_link('Maps')
    page.should have_content("bGeigie Import")
  end
  
end