#!/usr/bin/env bash

docker-compose run --rm --entrypoint bash -c "bundle exec rspec spec" app
