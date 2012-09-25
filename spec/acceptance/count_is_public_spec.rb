require 'spec_helper'

feature 'Publicly viewable measurement count' do
  let(:user) { Fabricate(:user) }
  let!(:m1) { Fabricate(:measurement, :value => 66, :user_id => user.id) }
  let!(:m2) { Fabricate(:measurement, :value => 60, :user_id => user.id) }
  let!(:m3) { Fabricate(:measurement, :value => 11, :user_id => user.id) }
  let!(:m4) { Fabricate(:measurement, :value => 64, :user_id => user.id) }
  let!(:m5) { Fabricate(:measurement, :value => 96, :user_id => user.id) }
  let!(:m6) { Fabricate(:measurement, :value => 68, :user_id => user.id) }

  scenario 'view http://maps.safecast.org/count' do
    visit('/count')
    page.should have_content('6 measurements')
  end
end
