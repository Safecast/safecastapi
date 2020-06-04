#!/usr/bin/env bash

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd -P )"

cd "$base_dir"/..

# In some situations the Postgres container may not have started completely yet
docker-compose run app bash -c "sleep 10 && bundle exec rake db:environment:set RAILS_ENV=development && bundle exec rake db:drop db:create db:structure:load && bundle exec rake db:bootstrap"

# Note that we don't use `db:test:prepare` here but instead use
# create/load under both the development and test environment. This is
# due to our use of postgis and structure.sql (as opposed to
# schema.rb).
docker-compose run app bash -c "RAILS_ENV='test' bundle exec rake db:environment:set RAILS_ENV=test && bundle exec rake db:drop db:create db:structure:load"
