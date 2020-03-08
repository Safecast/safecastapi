#!/usr/bin/env bash

docker-compose run --rm --entrypoint bash -c "RAILS_ENV='test' bundle exec rspec spec" app
