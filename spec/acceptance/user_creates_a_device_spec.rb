require 'spec_helper'

feature "User creates a new device when submitting a reading" do
  let(:user) { Fabricate(:user) }

  before { sign_in(user) }

  scenario "new device" do
    visit('/devices')
    click_link('Add a Device')

    fill_in('Manufacturer', :with => 'Safecast')
    fill_in('Model', :with => 'bGeigie')
    fill_in('Sensor', :with => 'LND-712')

    click_button('Save')
    expect(page).to have_content('LND-712')
  end
end
