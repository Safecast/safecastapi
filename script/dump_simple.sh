#!/bin/bash

OUTPUT_DIR=/data/safecastapi/shared/system
DB_SERVER=localhost

# FIXME: check we are not running already by implementing PID file lock
# start on clean
rm -f /mnt/tmp/simple_dataset.csv.tmp

# dump the data
# FIXME: altitude is also needed!
psql -U deploy -h ${DB_SERVER} safecastapi -c "\copy (SELECT captured_at, ST_Y(location::geometry), ST_X(location::geometry), value, measurement_import_id FROM measurements WHERE unit='cpm' ORDER BY captured_at) TO '/mnt/tmp/simple_dataset.csv.tmp' CSV;"

# add header and bzip2 the result
echo "timestamp,lat,lon,CPM,import_id" | cat - /mnt/tmp/simple_dataset.csv.tmp |bzip2 - > ${OUTPUT_DIR}/simple_dataset.csv.tmp.bz2

# rename/overwrite the old file
mv ${OUTPUT_DIR}/simple_dataset.csv{.tmp,}.bz2

#
# You can get this at https://api.safecast.org/system/simple_dataset.csv.bz2
#
