#@IgnoreInspection BashAddShebang

[[ -f /opt/elasticbeanstalk/support/envvars ]] && source /opt/elasticbeanstalk/support/envvars

export PGHOST="${DATABASE_HOST}"
export PGPORT=5432
export PGDATABASE="${DATABASE_NAME:-safecast}"
export PGUSER=safecast
export PGPASSWORD="${DATABASE_PASSWORD}"

export CRON_DIR="$(pwd)"
