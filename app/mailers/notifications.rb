class Notifications < ActionMailer::Base
  default :from => "mailer@safecast.org"
  default_url_options[:locale] = "en-US"

  def import_approved(import)
    mail(
      :to => import.user.email,
      :subject => "Your Safecast import has been approved")
  end

  def import_awaiting_approval(import)
    moderators = User.moderator.collect(&:email)
    mail(
      :to => moderators, 
      :subject => "A Safecast import is awaiting approval")
  end
end
