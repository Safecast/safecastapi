feature 'Password reset', type: :feature do
  scenario 'user visits "Forgot your password?" page' do
    visit('/en-US/users/sign_in')

    click_link 'Forgot your password?'

    expect(page).to have_content('Forgot your password?')
  end
end
