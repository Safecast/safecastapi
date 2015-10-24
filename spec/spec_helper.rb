# Send test-coverage to code climate
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

# Loading more in this block will cause your tests to run faster. However,
# if you change any configuration or code from libraries loaded here, you'll
# need to restart spork for it take effect.
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'fileutils'
require 'email_spec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include Helpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include ActionDispatch::TestProcess

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.before(:all) do
    FileUtils.rm_rf Dir[Rails.root.join('tmp', 'cache', 'assets', '**', '*')]
  end

  config.after(:all) do
    FileUtils.rm_f Rails.root.join('tmp', 'capybara', '*')
    FileUtils.rm_rf Dir[Rails.root.join('tmp', 'cache', 'assets', '**', '*')]
    FileUtils.rm_rf Dir[Rails.root.join('public', 'uploads', '**', '*')]
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
