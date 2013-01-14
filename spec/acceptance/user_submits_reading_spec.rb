require 'spec_helper'

feature "User submits a reading when a device does not exist" do
  let(:user) { Fabricate(:user) }
  let(:measurement) { user.measurements.last }

  before { sign_in(user) }
  
  scenario "first reading" do
    visit('/')
    click_link('Submit')
    select('Clicks Per Minute', :from => 'Unit')
    fill_in('Radiation Level', :with => '123')
    fill_in('Location',        :with => 'Colwyn Bay, Wales')
    click_button('Submit')
    page.should have_content('123')
    page.should have_content('cpm')
    user.should have(1).measurements
    measurement.value.should == 123
    measurement.location_name.should == 'Colwyn Bay, Wales'
  end
end

feature "User submits a reading while devices exist" do
  let(:user) { Fabricate(:user) }
  let(:measurement) { user.measurements.last }
  let(:device) { Fabricate(:device) }

  before do
    sign_in(user)
    device.save!
  end

  scenario 'reading with no device' do
    visit('/')
    click_link('Submit')
    select('Clicks Per Minute', :from => 'Unit')
    fill_in('Radiation Level',  :with => '456')
    fill_in('Location',         :with => 'Los Angeles, CA')
    select('', :from => 'Device')
    click_button('Submit')
    page.should have_content('456')
    page.should have_content('cpm')
    measurement.value.should == 456
    measurement.device.should == nil
  end

  scenario 'reading with a device' do
    visit('/')
    click_link('Submit')
    select('Clicks Per Minute', :from => 'Unit')
    fill_in('Radiation Level',  :with => '789')
    fill_in('Location',         :with => 'Tokyo, JP')
    select(device.name, :from => 'Device')
    click_button('Submit')
    page.should have_content('789')
    page.should have_content('cpm')

    measurement.value.should == 789
    measurement.device.should == device

  end
end
