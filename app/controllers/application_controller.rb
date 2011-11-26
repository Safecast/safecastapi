class ApplicationController < ActionController::Base
  protect_from_forgery
  force_ssl if Rails.env.production?
end