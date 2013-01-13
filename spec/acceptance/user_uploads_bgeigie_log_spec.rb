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
      Delayed::Worker.new.work_off 
      visit(current_path)
      page.should have_content('Awaiting approval')
      ImportAwaitingApprovalDigestMailer.queuedImports.length.should == 1
    end
  end
  
  context "as a moderator" do
    let!(:bgeigie_import) { Fabricate(:bgeigie_import, :user => user) }

    before do
      bgeigie_import.process
    end

    scenario "approving a bGeigie log file" do
      sign_in(moderator)
      visit('/')
      page.should have_content('1 imports awaiting approval')
      click_link '1 imports awaiting approval'
      click_link 'bgeigie.log'
      click_button 'Approve'
      Delayed::Worker.new.work_off 
      visit(current_path)
      page.should have_content('Processed')
      find_email(user.email, 
        :with_subject => 'Your Safecast import has been approved').should be_present
    end
  end
end
