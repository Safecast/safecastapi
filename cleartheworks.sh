#!/usr/bin/env bash

# This is mildly silly, but until we address https://github.com/Safecast/safecastapi/issues/726 and https://github.com/Safecast/safecastapi/issues/799
# we'll continue to get backups at the database layer. If alerts fire regarding DB space or outstanding tasks in the queue, run this to clear everything out.

# Run this from a location that ssh to rt.safecast.org as well as run SQS purge. Probably an administrator's workstation.

set -euo pipefail

# Get the current prd-wek environment and it's queue URL
BEANSTALK_ENVIRONMENT=$(eb list | grep prd-wrk)
QUEUE_URL=$(eb ssh "${BEANSTALK_ENVIRONMENT}" \
    --quiet --command '/opt/elasticbeanstalk/bin/get-config meta -k sqsdconfig | jq -r .queue_url')

# stop worker, purge queue and stop any rt scraper processes
eb ssh "${BEANSTALK_ENVIRONMENT}" --quiet --command 'sudo systemctl stop web'
aws sqs purge-queue --queue-url "${QUEUE_URL}"
ssh rt.safecast.org 'sudo killall php || true'

# stop any in-flight DB queries > 5s
eb ssh "${BEANSTALK_ENVIRONMENT}" --quiet --command 'psql -c "select pg_terminate_backend(pid)
from pg_stat_activity
where state != '"'"idle"'"' and query_start < now() - interval '"'"'5 seconds'"'"';"'

# restart worker
eb ssh "${BEANSTALK_ENVIRONMENT}" --quiet --command 'sudo systemctl start web'
