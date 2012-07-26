# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Safecast::Application.initialize!

config.action_mailer.delivery_method = :sendmail  
config.action_mailer.sendmail_settings = {:arguments => "-i"}
