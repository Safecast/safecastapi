require 'spec_helper'

feature "User creates a device when submitting a reading" do
  let(:user) { Fabricate(:user) }

  before do
    sign_in(user)
    visit('/')
    click_link('Submit')
    click_link('Add a new device')
  end


  scenario "new generic device" do
    fill_in('Manufacturer', :with => 'Safecast')
    fill_in('Model', :with => 'bGeigie')
    fill_in('Sensor', :with => 'LND-712')

    click_button('Submit')

    select('Clicks per minute', :from => 'Unit')
    fill_in('Radiation Level',  :with => '12.3')
    fill_in('Location',         :with => 'Los Angeles, CA')
    select('Safecast - bGeigie (LND-712)', :from => 'Device')
    click_button('Submit')

    page.should have_content('12.3')
    page.should have_content('cpm')
    page.should have_content('Safecast - bGeigie (LND-712)')

    user.measurements.last.device.name.should == 'Safecast - bGeigie (LND-712)'
  end

  scenario "new radiation device" do
    visit('/')
    click_link('Submit')
    click_link('Add a new device')
    click_link('Add a Radiation Sensor')

    fill_in('Manufacturer', :with => 'LND')
    fill_in('Model', :with => 'LND-712')
    fill_in('Serial Number', :with => '12345')

    select('Geiger Tube', :from => 'Sensor Type')

    check('Alpha')
    check('Beta')
    uncheck('Gamma')

    click_button('Submit')

    fill_in('Manufacturer', :with => 'Safecast')
    fill_in('Model', :with => 'bGeigie')
    select('LND-712', :from => 'Sensor')

    click_button('Submit')

    select('Clicks per minute', :from => 'Unit')
    fill_in('Radiation Level',  :with => '12.3')
    fill_in('Location',         :with => 'Los Angeles, CA')
    select('Safecast - bGeigie (LND-712)', :from => 'Device')
    click_button('Submit')

    page.should have_content('12.3')
    page.should have_content('cpm')
    page.should have_content('Safecast - bGeigie (LND-712)')

    user.measurements.last.device.name.should == 'Safecast - bGeigie (LND-712)'
  end
end
