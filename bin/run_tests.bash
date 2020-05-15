#!/usr/bin/env bash

docker-compose run app bash -c "bundle exec rspec spec" --rm --entrypoint
