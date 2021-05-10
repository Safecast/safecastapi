# frozen_string_literal: true

require 'spec_helper'

feature 'User uploads bgeigie log', type: :feature do
  let!(:user) { Fabricate(:user) }
  let!(:moderator) { Fabricate(:user, moderator: true) }

  context 'as a regular user' do
    scenario 'uploading a bgeigie log file' do
      sign_in(user)
      visit('/')
      click_link('Submit')
      click_link('Upload a bGeigie log file')
      attach_file('File', Rails.root.join('spec', 'fixtures', 'bgeigie.log'))
      click_button('Upload')
      expect(page).to have_content('Unprocessed')
      fill_in 'Credits', with: 'Bill'
      fill_in 'Cities', with: 'Dublin'
      Delayed::Worker.new.work_off
      click_button 'Save'
      expect(page).to have_content('Processed')
      click_button 'Submit for Approval'
      expect(page).to have_content('Submitted')
      expect(find_email(Notifications::APPROVERS_LIST,
                        with_subject: 'A Safecast import is awaiting approval')).to be_present
    end
  end

  context 'as a moderator' do
    let!(:bgeigie_import) { Fabricate(:bgeigie_import, user: user) }

    before do
      bgeigie_import.process
      bgeigie_import.update(cities: 'Tokyo', credits: 'Bill', status: 'submitted')
    end

    scenario 'approving a bGeigie log file' do
      sign_in(moderator)
      visit('/')
      click_link 'Imports'
      click_link 'Submitted'
      click_link File.basename(bgeigie_import.source.filename)
      click_button 'Approve'
      Delayed::Worker.new.work_off
      visit(current_path)
      expect(page).to have_content('Processed')
      expect(find_email(user.email,
                        with_subject: 'Your Safecast import has been approved')).to be_present
    end
  end
end
