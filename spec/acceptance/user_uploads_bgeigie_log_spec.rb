require 'spec_helper'

feature "User uploads bgeigie log" do
  
  before { sign_in_user('paul@rslw.com') }
  let(:user) { User.find_by_email('paul@rslw.com') }
  
  scenario "Uploading a bgeigie log file" do
    visit('/')
    click_link('Submit')
    click_link('Upload a bGeigie log file')
    attach_file("File", Rails.root.join('spec', 'fixtures', 'bgeigie.log'))
    click_button("Upload")
    page.should have_content('unprocessed')
    Delayed::Worker.new.work_off 
    page.should have_content('Awaiting approval')
    click_link('Maps')
    page.should have_content("bGeigie Import")
  end
  
end