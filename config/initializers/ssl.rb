require "rack/ssl"
Safecast::Application.middleware.use ::Rack::SSL
#support SSL and not SSL.  this is in lieu of force_ssl in application controller.
Safecast::Application.config.middleware.insert_before ActionDispatch::Static, Rack::SSL, :exclude => proc { |env| env['HTTPS'] != 'on' }
