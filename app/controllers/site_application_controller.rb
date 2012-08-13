class SiteApplicationController < ApplicationController
  force_ssl if Rails.env.production?
end