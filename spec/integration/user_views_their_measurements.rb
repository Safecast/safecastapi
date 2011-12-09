require 'spec_helper'

feature "User Submits Reading" do
  
  before { sign_in_user('paul@rslw.com') }
  let(:user) { User.find_by_email('paul@rslw.com') }
  let!(:measurement) { Fabricate(:measurement, :user => user, :value => 10101) }
  
  scenario "First Reading", :js => true do
    visit('/')
    click_link('My Measurements')
    page.should have_content('10101')
  end
  
end