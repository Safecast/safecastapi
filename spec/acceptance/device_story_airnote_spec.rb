# frozen_string_literal: true

feature 'AirNote device story', type: :feature do
  let(:device_story) { Fabricate(:device_story) }

  scenario 'view AirNote device story' do
    visit("/airnote/#{device_story.device_urn}")

    expect(page).to have_content("(#{device_story.device_urn})")
  end
end
