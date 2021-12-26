# frozen_string_literal: true

require 'spec_helper'

feature 'User Profile', type: :feature do
  let(:user) { Fabricate(:user) }
  before { sign_in(user) }

  after(:all) { I18n.locale = I18n.default_locale }

  scenario 'viewing a user profile' do
    expect(page).to have_content(user.authentication_token)
  end

  scenario 'edit profile' do
    click_link user.email
    click_link 'Profile'
    click_link 'Edit Profile'
    fill_in 'Name', with: 'John Doe'
    select 'ja', from: 'Default Locale'
    click_button 'Update User'

    expect(page).to have_current_path(dashboard_path(locale: 'ja'))
    expect(page).to have_content('Safecast API センターにようこそ！')
  end

  scenario 'change password' do
    click_link user.email
    click_link 'Profile'
    click_link 'Change Password'
    fill_in 'Password', with: '123456'
    fill_in 'Password confirmation', with: '123456'
    within('#change-password') do
      click_button 'Update User'
    end

    expect(page).to have_content('Sign in')
  end
end
