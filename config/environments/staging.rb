require_relative 'production'

Safecast::Application.configure do
  config.action_mailer.default_url_options = {
    host: 'api-staging.safecast.org',
    protocol: 'http'
  }
end
