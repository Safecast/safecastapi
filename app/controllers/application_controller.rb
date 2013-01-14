class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale

  respond_to :html, :json, :safecast_api_v1_json 

  before_filter :cors_set_access_control_headers
  skip_before_filter :verify_authenticity_token

  def index
    cors_set_access_control_headers
    result = { }
    respond_with @result = @doc 
  end

  def options
    cors_set_access_control_headers
    render :text => '', :content_type => 'application/json'
  end
    
protected
  
  def rescue_action(env)
    respond_to do |wants|
      wants.json { render :json => "Error", :status => 500 }
    end
  end

  def cors_set_access_control_headers
    return unless request.env['HTTP_ACCEPT'].eql? 'application/json'
    if current_user 
      host = request.env['HTTP_ORIGIN']
    else 
      host = request.env['HTTP_ORIGIN']
      unless /safecast.org$/.match host
        host = 'safecast.org'
      end
    end
    headers['Access-Control-Allow-Origin'] = host
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*, X-Requested-With'
    headers['Access-Control-Max-Age'] = '100000'
  end
 
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