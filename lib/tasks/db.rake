# frozen_string_literal: true

# XXX: remove tasks defined by activerecord-postgis-adapter and define
#      our own because
#        was too clever and does not work well with a single
#        `structure.sql` being provided for all environments
#      (originally from config/initializers/postgis.rb)
Rake.application.instance_eval do
  %w(db:structure:dump db:structure:load).each do |task|
    @tasks.delete(task)
  end
end

schema_file = ::Rails.root.join('db/structure.sql')

namespace :db do
  namespace :schema do
    desc 'Alias for db:structure:load'
    task load: ['db:structure:load']
  end

  namespace :structure do
    desc 'Dump db schema structure.sql'
    task dump: [:environment] do
      setup_psql_env
      system('pg_dump', '-s', '-x', '-O', '-f', schema_file.to_s)
      raise 'Error dumping database' unless $CHILD_STATUS.success?

      schema_file.open(::File::RDWR | ::File::APPEND) do |f|
        f.puts(::ActiveRecord::Base.connection.dump_schema_information)
        f.puts
      end
    end

    desc 'Load db schema from structure.sql'
    task load: [:environment] do
      if ActiveRecord::SchemaMigration.table_exists?
        raise "#{ActiveRecord::SchemaMigration.table_name} already exists, please run rake db:drop to wipe DB before load"
      end

      setup_psql_env
      [
        ['-c', 'drop extension if exists postgis'],
        ['-c', 'drop schema if exists postgis cascade'],
        ['-f', schema_file.to_s],
        ['-c', 'GRANT ALL ON postgis.geometry_columns TO PUBLIC'],
        ['-c', 'GRANT ALL ON postgis.spatial_ref_sys TO PUBLIC']
      ].each do |args|
        system('psql', *args)
      end
    end

    def setup_psql_env
      ::ActiveRecord::Base.configurations[Rails.env]
        .extract!('database', 'host', 'port', 'password', 'username')
        .compact
        .each do |key, val|
          key = 'user' if key == 'username'
          ::ENV["PG#{key.upcase}"] = val.to_s
        end
    end
  end
end
