require 'spec_helper'

feature "User uploads bgeigie log" do
  
  before { sign_in_user('paul@rslw.com') }
  let(:user) { User.find_by_email('paul@rslw.com') }
  
  context "regular user" do
    scenario "Uploading a bgeigie log file" do
      visit('/')
      click_link('Submit')
      click_link('Upload a bGeigie log file')
      attach_file("File", Rails.root.join('spec', 'fixtures', 'bgeigie.log'))
      click_button("Upload")
      page.should have_content('Unprocessed')
      Delayed::Worker.new.work_off 
      visit(current_path)
      page.should have_content('Awaiting approval')
    end
  end
  
  context "moderator" do
    let!(:other_user) { Fabricate(:user) }
    let!(:bgeigie_import) do
      Fabricate(:bgeigie_import,
                :source => File.new(Rails.root + 'spec/fixtures/bgeigie.log'),
                :user_id => other_user.id)
    end

    before do
      user.moderator = true
      user.save!
      bgeigie_import.process
    end

    scenario "approving a bGeigie log file" do
      visit('/')
      page.should have_content('1 awaiting approval')
    end
  end
  
end