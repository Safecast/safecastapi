#!/bin/sh

VISIBILITY_TIMEOUT=$(/opt/elasticbeanstalk/bin/get-config meta -k sqsdconfig | jq -r .visibility_timeout)
if [ -n "$VISIBILITY_TIMEOUT" ]; then
  echo 'worker: bundle exec rails jobs:work' >> /var/app/staging/Procfile
fi
