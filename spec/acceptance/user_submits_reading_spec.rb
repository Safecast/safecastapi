# frozen_string_literal: true

require 'spec_helper'

feature 'User submits a reading when a device does not exist', type: :feature do
  let(:user) { Fabricate(:user) }
  let(:measurement) { user.measurements.last }

  before { sign_in(user) }

  scenario 'first reading' do
    visit('/')
    click_link('Submit')
    select('Clicks Per Minute', from: 'Unit')
    fill_in('Radiation Level', with: '123')
    fill_in('Location',        with: 'Colwyn Bay, Wales')
    click_button('Submit')
    expect(page).to have_content('123')
    expect(page).to have_content('cpm')
    expect(user.measurements.count).to eq(1)
    expect(measurement.value).to eq(123)
    expect(measurement.location_name).to eq('Colwyn Bay, Wales')
  end
end

feature 'User submits a reading while devices exist', type: :feature do
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
    select('Clicks Per Minute', from: 'Unit')
    fill_in('Radiation Level',  with: '456')
    fill_in('Location',         with: 'Los Angeles, CA')
    select('', from: 'Device')
    click_button('Submit')
    expect(page).to have_content('456')
    expect(page).to have_content('cpm')
    expect(measurement.value).to eq(456)
    expect(measurement.device).to eq(nil)
  end

  scenario 'reading with a device' do
    visit('/')
    click_link('Submit')
    select('Clicks Per Minute', from: 'Unit')
    fill_in('Radiation Level',  with: '789')
    fill_in('Location',         with: 'Tokyo, JP')
    select(device.name, from: 'Device')
    click_button('Submit')
    expect(page).to have_content('789')
    expect(page).to have_content('cpm')

    expect(measurement.value).to eq(789)
    expect(measurement.device).to eq(device)
  end
end
