require "spec_helper"

feature "User uploads bgeigie log" do
  let!(:user) { Fabricate(:user) }
  let!(:moderator) { Fabricate(:user, :moderator => true) }

  context "as a regular user" do
    scenario "uploading a bgeigie log file" do
      sign_in(user)
      visit('/')
      click_link('Submit')
      click_link('Upload a bGeigie log file')
      attach_file("File", Rails.root.join('spec', 'fixtures', 'bgeigie.log'))
      click_button("Upload")
      page.should have_content('Unprocessed')
      fill_in 'Credits', :with => 'Bill'
      fill_in 'Cities', :with => 'Dublin'
      Delayed::Worker.new.work_off
      click_button 'Save'
      page.should have_content('Processed')
      click_button 'Submit for Approval'
      page.should have_content('Submitted')
      find_email(moderator.email, 
        :with_subject => 'A Safecast import is awaiting approval').should be_present
    end
  end
  
  context "as a moderator" do
    let!(:bgeigie_import) { Fabricate(:bgeigie_import, :user => user) }

    before do
      bgeigie_import.process
      bgeigie_import.update_attributes(:cities => 'Tokyo', :credits => 'Bill', :status => 'submitted')
    end

    scenario "approving a bGeigie log file" do
      sign_in(moderator)
      visit('/')
      click_link 'Imports'
      click_link 'Submitted'
      click_link 'bgeigie0.log'
      click_button 'Approve'
      Delayed::Worker.new.work_off 
      visit(current_path)
      page.should have_content('Processed')
      find_email(user.email, 
        :with_subject => 'Your Safecast import has been approved').should be_present
    end
  end
end
