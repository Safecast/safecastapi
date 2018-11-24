# frozen_string_literal: true

feature 'Creating new mesurement', type: :feature do
  let(:user) { Fabricate(:user) }
  let!(:device) { Fabricate(:device) }

  before do
    sign_in(user)
  end

  # https://github.com/Safecast/safecastapi/issues/166
  scenario 'User creates new measurement in uSv/h and view it in index page with filter' do
    visit(new_measurement_path(locale: 'en-US'))

    fill_in('Radiation Level', with: '123')
    select('μSv/h', from: 'Unit')
    fill_in('Latitude', with: '35.52')
    fill_in('Longitude', with: '141.67')
    select('Safecast - bGeigie (LND-7317)', from: 'Device')

    click_button('Submit')

    # Filter by unit = usv, longitude = 35.5, and latitude = 141.6
    visit(measurements_path(unit: 'usv', longitude: '141.6', latitude: '35.5', locale: 'en-US'))

    doc = Nokogiri.HTML(page.body)
    rows = doc.xpath('//table/tbody/tr')
    expect(rows.size).to eq(1) # measurement just created should be shown
  end
end
