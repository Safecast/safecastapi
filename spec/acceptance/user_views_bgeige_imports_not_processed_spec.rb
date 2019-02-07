# frozen_string_literal: true

feature 'User views unprocessed bGeigie imports', type: :feature do
  let!(:user) { Fabricate(:admin_user) }
  let!(:bgeigie_import) { Fabricate(:bgeigie_import, user: user, name: 'my import', status: 'submitted') }

  scenario 'viewing bGeigie imports' do
    sign_in(user)
    visit('/bgeigie_imports/not_processed')
    # TODO: add some expectations
  end
end
