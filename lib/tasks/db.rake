namespace :db do
  #NOTE: Newer versions of rails should support this in schema.rb. Ours doesn't atm.
  desc 'Creates the postgis extension on the datatabase'
  task :enable_postgis => :environment do
    # for some reason `create extension if exists` doesn't work with how the
    # extension is normally getting added, so we'll look for the postgis schema
    # instead
    c = ActiveRecord::Base.connection
    postgis_tables = c.exec_query <<-SQL
      select * from information_schema.tables
        where table_catalog = '#{c.current_database}' and
              table_schema = 'postgis'
    SQL

    if postgis_tables.count == 0
      c.exec_query('CREATE EXTENSION postgis')
    end
  end
end
task 'db:schema:load' => 'db:enable_postgis'
