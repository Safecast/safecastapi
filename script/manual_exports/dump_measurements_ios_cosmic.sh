#!/bin/sh

rm -f /tmp/ios13_32_cosmic*

#psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/cosmic.sql
PGOPTIONS=--search_path=public,postgis psql -f /var/app/current/script/manual_exports/cosmic.sql
/bin/sleep 60s


cd /tmp

/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_cosmic.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_cosmic.sqlite
/bin/sleep 60s


cp /tmp/ios13_32_cosmic*.sqlite /var/app/current/public/system/

rm -f /tmp/ios13_32_cosmic*

