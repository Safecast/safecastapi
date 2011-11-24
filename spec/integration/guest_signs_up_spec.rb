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
  
  scenario 'signing up' do
    sign_up
    page.should have_content('My Dashboard')
  end
  
end