class Notifications < ActionMailer::Base
  default from: 'mailer@safecast.org'
  default_url_options[:locale] = 'en-US'

  APPROVERS_LIST = 'approvers@safecast.org'.freeze

  def import_approved(import)
    @import = import
    mail(
      to: import.user.email,
      subject: "Your Safecast import has been approved - #{import.filename}"
    )
  end

  def import_rejected(import)
    @import = import
    mail(
      to: import.user.email,
      subject: "Your Safecast import has been rejected - #{import.filename}"
    )
  end

  def import_awaiting_approval(import)
    moderators = APPROVERS_LIST
    return if moderators.empty?
    @import = import
    mail(
      to: moderators,
      subject: "A Safecast import is awaiting approval - #{import.filename}"
    )
  end

  def send_email(import, body, sender)
    @import = import
    @body = body
    @sender = sender
    mail(
      from: sender,
      to: import.user.email,
      subject: "Email from Safecast Moderator regarding your Safecast Import - #{import.filename}"
    )
  end

  def contact_moderator(import, body, sender)
    @import = import
    @body = body
    @sender = sender
    mail(
      from: sender,
      to: import.rejected_by,
      subject: "Email from Safecast User regarding Safecast Import - #{import.filename}"
    )
  end
end
