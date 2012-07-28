class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
 
protected
  def require_moderator
    redirect_to root_path unless user_signed_in? and current_user.moderator?
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end
end
