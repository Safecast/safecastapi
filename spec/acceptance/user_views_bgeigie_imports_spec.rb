# frozen_string_literal: true

describe 'User views bGeigie imports', type: :feature do
  let(:user) { Fabricate(:user) }

  before do
    Fabricate(:bgeigie_import, user: user, name: 'sample', status: 'processed')
  end

  it 'is able to sort bGeigie imports by comment' do
    visit bgeigie_imports_path(locale: 'en-US')

    click_on 'Comment'

    expect(page).to have_xpath("//i[contains(@class, 'glyphicon-chevron-down')]/parent::a[contains(text(), 'Comment')]")
  end
end
