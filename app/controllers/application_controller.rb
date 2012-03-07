class ApplicationController < ActionController::Base
  protect_from_forgery
  force_ssl if Rails.env.production?

protected
  def require_moderator
    redirect_to root_path unless user_signed_in? and current_user.moderator?
  end
end