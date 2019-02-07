# frozen_string_literal: true

feature 'Showing a bGeigie import', type: :feature do
  let(:user) { Fabricate(:user) }
  let(:bgeigie_import) { Fabricate(:bgeigie_import, user: user) }

  scenario 'login user sees link to delete own import' do
    sign_in user
    visit bgeigie_import_path(bgeigie_import, locale: 'en-US')
    expect(page).to have_xpath('//a[text()="Delete this Import"]')
  end

  scenario 'moderator user sees link to delete any import' do
    sign_in Fabricate(:admin_user)
    visit bgeigie_import_path(bgeigie_import, locale: 'en-US')
    expect(page).to have_xpath('//a[text()="Delete this Import"]')
  end

  scenario 'non-login user does not see link to delete any import' do
    visit bgeigie_import_path(bgeigie_import, locale: 'en-US')
    expect(page).to_not have_xpath('//a[text()="Delete this Import"]')
  end

  scenario 'login user does not see link to delete other import' do
    sign_in Fabricate(:user)
    visit bgeigie_import_path(bgeigie_import, locale: 'en-US')
    expect(page).to_not have_xpath('//a[text()="Delete this Import"]')
  end
end
