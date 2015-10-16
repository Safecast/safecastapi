namespace :db do
  #NOTE: Newer versions of rails should support this in schema.rb. Ours doesn't atm.
  desc 'Creates the postgis extension on the datatabase'
  task :enable_postgis => :environment do
    connection = ActiveRecord::Base.connection
    connection.exec_query('CREATE EXTENSION IF NOT EXISTS postgis')
  end
end
task 'db:schema:load' => 'db:enable_postgis'
