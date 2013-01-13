class Notifications < ActionMailer::Base
  default :from => "mailer@safecast.org"
  default_url_options[:locale] = "en-US"

  def import_approved(import)
    @import = import
    mail(
      :to => import.user.email,
      :subject => "Your Safecast import has been approved")
  end

  def import_awaiting_approval(import)
    moderators = User.moderator.collect(&:email)
    @import = import
    mail(
      :to => moderators, 
      :subject => "A Safecast import is awaiting approval")
  end

  def import_awaiting_approval_digest(imports)
    moderators = User.moderator.collect(&:email)
    @imports = imports
    pluralized_imports = @imports.length > 1 ? "imports are" : "import is"
    mail(
      :to => moderators,
      :subject => "#{@imports.length} new Safecast #{pluralized_imports} awaiting approval"
    )
  end
end
