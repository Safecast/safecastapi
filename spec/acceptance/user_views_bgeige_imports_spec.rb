# frozen_string_literal: true

require 'spec_helper'

feature 'User views bGeigie imports', type: :feature do
  let!(:user) { Fabricate(:user) }
  let!(:bgeigie_import) { Fabricate(:bgeigie_import, user: user, name: 'my import', status: 'done') }

  scenario 'viewing bGeigie imports' do
    sign_in(user)
    visit('/')
    click_link('Imports')
    expect(page).to have_content(File.basename(bgeigie_import.source.filename))
  end
end
