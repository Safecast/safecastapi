# frozen_string_literal: true

# TODO: move to controller spec
feature 'Publicly viewable measurement count', type: :feature do
  before do
    user = Fabricate(:user)
    Fabricate.times(6, :measurement, user: user) do
      value { sequence(:value, 10) }
    end
  end

  scenario 'view http://maps.safecast.org/count' do
    visit('/count')

    # Test can't assert 6 since switching to estimated row count
    expect(page).to have_content('0 measurements')
  end
end
