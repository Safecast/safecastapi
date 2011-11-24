require 'spec_helper'

feature 'guest signs up' do
  
  def sign_up(email = 'paul@rslw.com',
              name = 'Paul Campbell',
              password = 'mynewpassword')
    visit('/')
    fill_in('Email',    :with => email)
    fill_in('Name',     :with => name)
    fill_in('Password', :with => password)
    click_button('Sign in')
  end
  
  context("new user") do
    scenario 'signing up' do
      sign_up
      page.should have_content('My Dashboard')
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