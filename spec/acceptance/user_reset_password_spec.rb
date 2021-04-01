# frozen_string_literal: true

feature 'User resets password', type: :feature do
  let(:user) { Fabricate(:user, default_locale: 'en-US') }

  scenario 'User creates new measurement in uSv/h and view it in index page with filter' do
    visit(new_user_password_path)

    fill_in('Email', with: user.email)
    click_on('Send me reset password instruction')

    visit(reset_password_path_from_instruction_mail)

    fill_in('New password', with: 'secret1234')
    fill_in('Confirm new password', with: 'secret1234')
    click_on('Change my password')

    expect(page).to have_text('Your password has been changed successfully.')
  end

  def reset_password_path_from_instruction_mail
    mail = ActionMailer::Base.deliveries.last
    doc = Nokogiri.HTML(mail.body.raw_source)
    uri = URI(doc.xpath('//a').attribute('href').value)
    [uri.path, uri.query].join('?')
  end
end
