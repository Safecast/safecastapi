require 'spec_helper'

feature 'guest signs up' do
  
  context("new user") do
    scenario 'signing up' do
      sign_up
      page.should have_content('Sign out')
    end
  end

end