# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'device_story/version'

Gem::Specification.new do |s|
  s.name        = 'device_story'
  s.version     = DeviceStory::VERSION
  s.authors     = ['Eito Katagiri']
  s.email       = ['eitoball@gmail.com']
  s.homepage    = 'https://api.safecast.org'
  s.summary     = 'device story'
  s.description = 'device story'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 4.2.11'

  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'pg', '~> 0.15'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-performance'
  s.add_development_dependency 'rubocop-rails'
end
