# frozen_string_literal: true

feature 'User views not-approved bGeigie imports', type: :feature do
  let!(:user) { Fabricate(:admin_user) }
  let!(:bgeigie_import) { Fabricate(:bgeigie_import, user: user, name: 'my import', status: 'processed') }

  scenario 'viewing bGeigie imports' do # rubocop:disable RSpec/NoExpectationExample
    sign_in(user)
    visit('/bgeigie_imports/not_approved')
    # TODO: add some expectations
  end
end
