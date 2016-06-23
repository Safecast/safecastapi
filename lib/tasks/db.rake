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

namespace :db do
  namespace :structure do
    task dump: [:environment] do |_t|
      setup_psql_env
      system('pg_dump', '-s', '-x', '-O', '-f', schema_file.to_s)
      raise 'Error dumping database' unless $?.success?
      schema_file.open(::File::RDWR | ::File::APPEND) do |f|
        f.puts(::ActiveRecord::Base.connection.dump_schema_information)
        f.puts
      end
    end

    task load: [:environment] do |_t|
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
        .extract!(*%w(database host port password username))
        .reject { |_, v| v.nil? } # TODO: use `#compact` in Rails 4
        .each do |key, val|
          key = 'user' if key == 'username'
          ::ENV["PG#{key.upcase}"] = val
        end
    end

    def schema_file
      @schema_file ||= ::Rails.root.join('db/structure.sql')
    end
  end
end
