#!/bin/bash

OUTPUT_DIR=/data/teamdata/shared/system

#start clean
rm -f /tmp/simple_dataset.csv
#dump the data
psql -U deploy -h ec2-50-112-49-143.us-west-2.compute.amazonaws.com teamdata -c "\copy (SELECT captured_at, ST_Y(location::geometry), ST_X(location::geometry), height, value FROM measurements WHERE unit='cpm' ORDER BY captured_at) to '/tmp/simple_dataset.csv' csv;"
#add header and bzip2 the result
echo "timestamp,lat,lon,alt,CPM" | cat - /tmp/simple_dataset.csv |bzip2 - > ${OUTPUT_DIR}/simple_dataset.csv.bz2
#end clean
rm -f /tmp/simple_dataset.csv

#
# You can get this at https://api.safecast.org/system/simple_dataset.csv.bz2
#

