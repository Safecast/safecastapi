require 'spec_helper'

feature 'guest signs up' do
  
  context("new user") do
    scenario 'signing up' do
      sign_up
      page.should have_content('Sign out')
    end
  end
  
  context("existing user") do
    before do
      Fabricate(:user, :email => 'paul@rslw.com', :name => 'Paul Campbell')
    end
    
    scenario 'signing in', :js => true do
      visit('/')
      fill_in('Email', :with => 'paul@rslw.com')
      fill_in('Password', :with => 'monkeys')
      page.should have_content('Welcome back, Paul')
    end
  end
  
end