#!/usr/bin/env bash

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd -P )"

cd "$base_dir"/..

docker-compose run app bundle exec rake db:drop db:create db:structure:load
docker-compose run app bundle exec rake db:bootstrap


# Note that we don't use `db:test:prepare` here but instead use
# create/load under both the development and test environment. This is
# due to our use of postgis and structure.sql (as opposed to
# schema.rb).
docker-compose run app bash -c "RAILS_ENV='test' bundle exec rake db:drop db:create db:structure:load"
