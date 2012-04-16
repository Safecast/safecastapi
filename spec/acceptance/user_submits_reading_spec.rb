require 'spec_helper'

feature "User submits a reading" do
  let(:user) { Fabricate(:user) }
  let(:measurement) { user.measurements.last }

  before { sign_in(user) }
  
  scenario "first reading" do
    visit('/')
    click_link('Submit')
    select('cpm', :from => 'Unit')
    fill_in('Radiation Level', :with => '123')
    fill_in('Location',        :with => 'Colwyn Bay, Wales')
    click_button('Submit')
    page.should have_content('123 cpm')
    user.should have(1).measurements
    measurement.value.should == 123
    measurement.location_name.should == 'Colwyn Bay, Wales'
  end
end
