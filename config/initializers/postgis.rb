# The default ‘hack’ overrides in activerecord-postgis-adapter was too clever
# and does not work well with a single `structure.sql` being provided for all environments
# therefore a hack to fix that hack is required.

# See: activerecord-postgis-adapter-0.6.5/lib/active_record/connection_adapters/postgis_adapter/rails3/databases.rake

require 'active_record/connection_adapters/postgis_adapter/railtie'
require 'rgeo/active_record/task_hacker'
require 'rake'

::RGeo::ActiveRecord::TaskHacker.modify('db:structure:dump', nil, 'postgis') do |config|
  set_psql_env(config)
  filename = ::Rails.root.join('db', 'structure.sql')
  `pg_dump -i -U "#{config["username"]}" -s -x -O -f #{filename} #{config["database"]}`
  
  if $?.exitstatus == 1
    raise "Error dumping database"
  end
end

::RGeo::ActiveRecord::TaskHacker.modify('db:structure:load', nil, 'postgis') do |config|
  set_psql_env(config)
  filename = ::Rails.root.join('db', 'structure.sql')
  `psql -f #{filename} #{config["database"]}`
end
