#!/usr/bin/env bash

set -euo pipefail

psql -c "delete from schema_migrations;"

time \
  pg_dump \
    --host=localhost --port=15432 \
    --table=admins \
    --table=bgeigie_logs \
    --table=configurables \
    --table=delayed_jobs \
    --table=devices \
    --table=drive_logs \
    --table=ioslastexport \
    --table=maps \
    --table=maps_measurements \
    --table=measurement_import_logs \
    --table=measurement_imports \
    --table=measurements \
    --table=rails_admin_histories \
    --table=schema_migrations \
    --table=users \
    --data-only --format=custom |
  pg_restore \
    --dbname=safecast \
    --data-only --format=custom
