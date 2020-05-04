# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery

  respond_to :html, :json, :safecast_api_v1_json

  force_ssl if: :ssl_enabled?

  before_action :strict_transport_security
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_cors_headers
  skip_before_action :verify_authenticity_token
  before_action :new_relic_custom_attributes

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def index
    set_cors_headers
    respond_with @result = @doc
  end

  def options
    set_cors_headers
    render plain: '', content_type: 'application/json'
  end

  protected

  def rescue_action(_env)
    respond_to do |wants|
      wants.json { render json: 'Error', status: 500 }
    end
  end

  def set_cors_headers
    return unless request.format.json?

    host = request.env['HTTP_ORIGIN']
    unless current_user
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

  def ssl_enabled?
    # Override for deployed dev environments
    return false if ENV['SSL_CONFIGURED'] == 'false'

    # Don't redirect API-Gateway requests
    return false if request.format.symbol == :json || request.method == 'HEAD'

    # Don't redirect domains we don't have certs for
    return false unless %w(safecast.org safecast.cc).include? request.domain

    # Only redirect in production mode
    Rails.env.production?
  end

  def strict_transport_security
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains' if request.ssl?
  end
end
