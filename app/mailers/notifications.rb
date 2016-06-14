class Notifications < ActionMailer::Base
  default :from => "mailer@safecast.org"
  default_url_options[:locale] = "en-US"

  def import_approved(import)
    @import = import
    mail(
      :to => import.user.email,
      :subject => "Your Safecast import has been approved - " << import.filename)
  end

  def import_rejected(import)
    @import = import
    mail(
      :to => import.user.email,
      :subject => "Your Safecast import has been rejected - " << import.filename)
  end

  def import_awaiting_approval(import)
    moderators = User.moderator.collect(&:email)
    @import = import
    mail(
      :to => moderators, 
      :subject => "A Safecast import is awaiting approval")
  end
  
  def send_email(import, body)
    @import = import
    @body = body
    mail(
      :to => import.user.email,
      :subject => "Email from Safecast Moderator regarding your Safecast Import - " << import.filename,
      :body => body)
  end
end
