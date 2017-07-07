#!/bin/sh

rm -f /tmp/ios13_32_*

psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2011-03-10_2011-09-10.sql
/bin/sleep 60s
psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2011-09-10_2012-03-10.sql
/bin/sleep 60s
psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2012-03-10_2012-09-10.sql
/bin/sleep 60s
psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2012-09-10_2013-03-10.sql
/bin/sleep 60s

psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2013-03-10_2013-09-10.sql
/bin/sleep 60s
psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2013-09-10_2014-03-10.sql
/bin/sleep 60s
psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2014-03-10_2014-09-10.sql
/bin/sleep 60s
psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2014-09-10_2015-03-10.sql
/bin/sleep 60s

psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2015-03-10_2015-09-10.sql
/bin/sleep 60s
psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2015-09-10_2016-03-10.sql
/bin/sleep 60s
psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2016-03-10_2016-09-10.sql
/bin/sleep 60s
psql -U safecast --host $POSTGRESQL_ADDRESS safecast -f /var/deploy/api.safecast.org/web_head/current/script/manual_exports/2016-09-10_2017-03-10.sql
/bin/sleep 60s

cd /tmp
/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2011-03-10_2011-09-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2011-03-10_2011-09-10.sqlite
/bin/sleep 60s
/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2011-09-10_2012-03-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2011-09-10_2012-03-10.sqlite
/bin/sleep 60s
/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2012-03-10_2012-09-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2012-03-10_2012-09-10.sqlite
/bin/sleep 60s
/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2012-09-10_2013-03-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2012-09-10_2013-03-10.sqlite
/bin/sleep 60s

/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2013-03-10_2013-09-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2013-03-10_2013-09-10.sqlite
/bin/sleep 60s
/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2013-09-10_2014-03-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2013-09-10_2014-03-10.sqlite
/bin/sleep 60s
/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2014-03-10_2014-09-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2014-03-10_2014-09-10.sqlite
/bin/sleep 60s
/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2014-09-10_2015-03-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2014-09-10_2015-03-10.sqlite
/bin/sleep 60s

/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2015-03-10_2015-09-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2015-03-10_2015-09-10.sqlite
/bin/sleep 60s
/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2015-09-10_2016-03-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2015-09-10_2016-03-10.sqlite
/bin/sleep 60s
/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2016-03-10_2016-09-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2016-03-10_2016-09-10.sqlite
/bin/sleep 60s
/bin/echo -e "PRAGMA journal_mode=OFF;PRAGMA page_size=16384;CREATE TABLE ImpTemp(X VARCHAR(32), Y VARCHAR(32), Z VARCHAR(32));CREATE TABLE Grid1(ID INTEGER PRIMARY KEY, X INT, Y INT, Z INT);\n.separator ','\n.import /tmp/ios13_32_2016-09-10_2017-03-10.csv ImpTemp\nINSERT INTO Grid1(X,Y,Z) SELECT CAST(X AS INT), CAST(Y AS INT), CAST(CAST(Z AS INT)-32768 AS INT) FROM ImpTemp;DROP TABLE ImpTemp;VACUUM;" | sqlite3 /tmp/ios13_32_2016-09-10_2017-03-10.sqlite
/bin/sleep 60s


cp /tmp/ios13_32_*.sqlite /var/deploy/api.safecast.org/web_head/shared/system/

rm -f /tmp/ios13_32_*

rsync -Havq --bwlimit 10000 /var/deploy/api.safecast.org/web_head/shared/system/ios13_32_* horse.api.safecast.org.c66.me:/var/deploy/api.safecast.org/web_head/shared/system/