require 'spec_helper'

feature 'Guest signs up', type: :feature do
  context 'as a new user' do
    scenario 'signing up' do
      sign_up
      new_user = User.last
      new_user.confirmed_at = Time.now
      new_user.save
      new_user.password = 'mynewpassword'
      sign_in(new_user)
      expect(page).to have_content('Sign out')
    end
  end
end
