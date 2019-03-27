# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery

  respond_to :html, :json, :safecast_api_v1_json

  force_ssl if: :ssl_enabled?

  before_filter :strict_transport_security
  before_filter :set_locale
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :cors_set_access_control_headers
  skip_before_filter :verify_authenticity_token
  before_filter :new_relic_custom_attributes

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def index
    cors_set_access_control_headers
    respond_with @result = @doc
  end

  def options
    cors_set_access_control_headers
    render text: '', content_type: 'application/json'
  end

  protected

  def rescue_action(_env)
    respond_to do |wants|
      wants.json { render json: 'Error', status: 500 }
    end
  end

  def cors_set_access_control_headers # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return unless request.env['HTTP_ACCEPT'].eql? 'application/json'
    if current_user
      host = request.env['HTTP_ORIGIN']
    else
      host = request.env['HTTP_ORIGIN']
      host = 'safecast.org' unless /safecast.org$/ =~ host
    end
    headers['Access-Control-Allow-Origin'] = host
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*, X-Requested-With'
    headers['Access-Control-Max-Age'] = '100000'
  end

  def require_moderator
    return if current_user&.moderator?
    redirect_to root_path, alert: 'access_denied'
  end

  def set_locale
    I18n.locale = current_user.try(:default_locale).presence ||
                  params[:locale].presence ||
                  I18n.default_locale
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def default_url_options(_options = {})
    { locale: I18n.locale }
  end

  def new_relic_custom_attributes
    return unless current_user
    ::NewRelic::Agent.add_custom_attributes(user_id: current_user.id)
  end

  # API-Gateway needs to send in HTTP
  def ssl_enabled?
    Rails.env.production? && request.format.symbol != :json && request.method != 'HEAD'
  end

  def strict_transport_security
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains' if request.ssl?
  end
end
