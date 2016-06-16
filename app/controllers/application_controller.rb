class ApplicationController < ActionController::Base
  protect_from_forgery

  respond_to :html, :json, :safecast_api_v1_json 

  before_filter :set_locale
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :cors_set_access_control_headers
  skip_before_filter :verify_authenticity_token
  skip_after_filter :intercom_rails_auto_include if !Rails.env.production?
  before_filter :new_relic_custom_attributes

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  

  def index
    cors_set_access_control_headers
    respond_with @result = @doc 
  end

  def options
    cors_set_access_control_headers
    render :text => '', :content_type => 'application/json'
  end
    
protected
  
  def rescue_action(_env)
    respond_to do |wants|
      wants.json { render :json => "Error", :status => 500 }
    end
  end

  def cors_set_access_control_headers # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return unless request.env['HTTP_ACCEPT'].eql? 'application/json'
    if current_user 
      host = request.env['HTTP_ORIGIN']
    else 
      host = request.env['HTTP_ORIGIN']
      unless /safecast.org$/ =~ host
        host = 'safecast.org'
      end
    end
    headers['Access-Control-Allow-Origin'] = host
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*, X-Requested-With'
    headers['Access-Control-Max-Age'] = '100000'
  end
 
  def require_moderator
    unless user_signed_in? and current_user.moderator?
      set_flash_message(:alert, 'access_denied')
      redirect_to root_path 
    end
  end

  def set_locale
    if user_signed_in? && current_user.default_locale.present?
      I18n.locale = current_user.default_locale
    else
      I18n.locale = params[:locale] || I18n.default_locale
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end

  def default_url_options(_options={})
    { :locale => I18n.locale }
  end

  def new_relic_custom_attributes
    if current_user
      custom_attrs = { user_id: current_user.id }
      ::NewRelic::Agent.add_custom_attributes(custom_attrs)
    end
  end
end
