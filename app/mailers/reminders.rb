class Reminders < ActionMailer::Base
  default from: 'mailer@safecast.org'
  default_url_options[:locale] = 'en-US'

  def pending_imports(user)
    @imports = user.bgeigie_imports.pending
    mail(to: user.email, subject: 'Pending bGeigie Imports Reminder')
  end
end
