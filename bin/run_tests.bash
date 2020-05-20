#!/usr/bin/env bash

docker-compose run --rm app bash -c "bundle exec rspec spec"
