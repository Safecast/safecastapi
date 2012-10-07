require 'spec_helper'

feature "User creates a device when submitting a reading" do
  let(:user) { Fabricate(:user) }

  before(:each) do
    sign_in(user)
    visit('/')
    click_link('Submit')
    click_link('Add a new device')
  end

  scenario "new radiation device", :type => :request, :js => true do
    click_link('Add a new sensor')

    fill_in('Manufacturer', :with => 'LND')
    fill_in('Model', :with => '712')
    fill_in('Serial Number', :with => '12345')
    select('radiation', :from => 'Measurement Category')
    fill_in('Measurement Type', :with => 'gamma')

    click_button('Submit')

    fill_in('Manufacturer', :with => 'Safecast')
    fill_in('Model', :with => 'bGeigie')
    select('LND - 712', :from => 'device_sensor_ids') #for some reason capybara doesn't like :from => 'Sensor', possibly because it's a has_many?

    click_button('Submit')

    select('Clicks per minute', :from => 'Unit')
    fill_in('Radiation Level',  :with => '12.3')
    fill_in('Location',         :with => 'Los Angeles, CA')
    select('Safecast - bGeigie (LND - 712)', :from => 'Device')
    click_button('Submit')

    page.should have_content('12.3')
    page.should have_content('cpm')
    page.should have_content('Safecast - bGeigie (LND - 712)')

    user.measurements.last.device.name.should == 'Safecast - bGeigie (LND - 712)'
  end

  scenario 'new device without sensor' do
    fill_in('Manufacturer', :with => 'Safecast')
    fill_in('Model', :with => 'bGeigie')
    click_button('Submit')

    page.should have_content "Sensors can't be blank"
  end
end
