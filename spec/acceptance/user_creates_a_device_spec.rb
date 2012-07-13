require 'spec_helper'

feature "User creates a new device when submitting a reading" do
  let(:user) { Fabricate(:user) }

  before { sign_in(user) }

  scenario "new device" do
    visit('/')
    click_link('Submit')
    click_link('Add a device')

    fill_in('Manufacturer', :with => 'Safecast')
    fill_in('Model', :with => 'bGeigie')
    fill_in('Sensor', :with => 'LND-712')

    click_link('Add')

    select('Clicks per minute', :from => 'Unit')
    fill_in('Radiation Level',  :with => '12.3')
    fill_in('Location',         :with => 'Los Angeles, CA')
    select('Safecast - bGeigie (LND-712)', :from => 'Device')
    click_button('Submit')

    page.should have_content('12.3')
    page.should have_content('cpm')
    page.should have_content('Safecast - bGeigie (LND-712)')

    user.measurement.last.device.name.should == 'Safecast - bGeigie (LND-712)'
  end
end
