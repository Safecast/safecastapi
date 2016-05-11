# The default ‘hack’ overrides in activerecord-postgis-adapter was too clever
# and does not work well with a single `structure.sql` being provided for all environments
# therefore a hack to fix that hack is required.

# See: activerecord-postgis-adapter-0.6.5/lib/active_record/connection_adapters/postgis_adapter/rails3/databases.rake

require 'active_record/connection_adapters/postgis_adapter/railtie'
require 'rgeo/active_record/task_hacker'
require 'rake'

::RGeo::ActiveRecord::TaskHacker.modify('db:structure:dump', nil, 'postgis') do |config|
  set_psql_env(config)
  username = config['username']
  filename = ::Rails.root.join('db', 'structure.sql')
  database = config['database']
  `pg_dump -U "#{ username }" -s -x -O -f #{ filename } #{ database }`


  
  File.open(filename, 'a') { |f|
    f.puts ActiveRecord::Base.connection.dump_schema_information
    f.print "\n"
  }
  
  if $?.exitstatus == 1
    raise "Error dumping database"
  end
end

::RGeo::ActiveRecord::TaskHacker.modify('db:structure:load', nil, 'postgis') do |config|
  set_psql_env(config)
  filename = ::Rails.root.join('db', 'structure.sql')
  database = config["database"]
  `psql -c 'drop extension if exists postgis' #{ database }`
  `psql -c 'drop schema if exists postgis cascade' #{ database }`
  `psql -f #{ filename } #{ database }`
  `psql -c 'GRANT ALL ON postgis.geometry_columns TO PUBLIC' #{ database }`
  `psql -c 'GRANT ALL ON postgis.spatial_ref_sys TO PUBLIC' #{ database }`
end
