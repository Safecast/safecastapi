# frozen_string_literal: true

class Reminders < ApplicationMailer
  default from: 'mailer@safecast.org'
  default_url_options[:locale] = 'en-US'

  def pending_imports(user)
    @imports = user.bgeigie_imports.pending
    mail(to: user.email, subject: 'Reminder: Your Safecast bGeigie logs')
  end
end
