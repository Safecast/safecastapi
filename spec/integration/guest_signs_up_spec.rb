require 'spec_helper'

feature 'guest signs up' do
  
  scenario 'signing up' do
    visit('/')
    fill_in('Email',    :with => 'paul@rslw.com')
    fill_in('Name',     :with => 'Paul Campbell')
    fill_in('Password', :with => 'mynewpassword')
    click_button('Sign in')
    last_response.should have_content('My Dashboard')
  end
  
end