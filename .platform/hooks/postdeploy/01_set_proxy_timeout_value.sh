#!/bin/sh

VISIBILITY_TIMEOUT=$(/opt/elasticbeanstalk/bin/get-config meta -k sqsdconfig | jq -r .visibility_timeout)
if [ -n "$VISIBILITY_TIMEOUT" ]; then
  echo "proxy_read_timeout ${VISIBILITY_TIMEOUT}s;" > /etc/nginx/conf.d/worker.conf
else
  echo "proxy_read_timeout 600s;" > /etc/nginx/conf.d/web.conf
fi
