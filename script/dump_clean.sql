SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 2014-10-25 ND: add minor filtering, new device support.

-- =========================
-- ABSTRACT
-- =========================
-- dump_clean and its SQL query, dump_clean.sql, perform a filtered dump of the measurements table per user request.
--
-- The filtering is the same as that used by the iOS app.
--
-- This differs from dump_measurements, which does not filter data at all.
-- The schema returned is also different; redundant/unused columns have been eliminated, and id/user_id finally included.
-- The ORDER BY clause was removed for performance.
--

-- todo: test if this can be multiline, it's difficult to read and maintain in this form

\copy (select id, user_id, captured_at, ST_Y(location::geometry), ST_X(location::geometry), value, unit, device_id from measurements WHERE id NOT BETWEEN 23181608 AND 23182462 AND id NOT BETWEEN 20798302 AND 20803607 AND id NOT BETWEEN 21977826 AND 21979768 AND id NOT BETWEEN 24060795 AND 24067649 AND id NOT IN (13194822,15768545,15768817,15690104,15768346,15768782,15768792,16381794,18001818,17342620,14669786,25389168,25389158,25389157,25389153,24482487,16537265,16537266,19554057,19554058,19554059,19554060,19555677,19589301,19589302,19589303,19589304,19589305,19589303,19589304,19589305,19600634,19699406,17461603,17461607,17461611,17461615,16981355,16240105,16240101,16240097,16240093,16241392,16241388,18001769,25702033,25702031) AND id NOT IN (14764408,14764409,14764410,14764411,14764412,14764413,13872611,13872612,14764388,14764389,14764390,14764391,14764392,14764393,14764394,14764395,14764396,14764397,14764398,14764399,14764400,14764401,14764402,14764403,14764404,14764405,14764406,14764407) AND id NOT IN (33708769,33708779,33709181,33709199,33709164,39366523,39417687) AND user_id NOT IN (345) AND captured_at > TIMESTAMP '2011-03-01 00:00:00' AND captured_at < localtimestamp + interval '48 hours' AND captured_at IS NOT NULL AND value IS NOT NULL AND location IS NOT NULL AND ((unit  = 'cpm' AND ((device_id IS NULL AND value BETWEEN 10.00 AND 350000.0) OR ((device_id <= 24 OR device_id IN (69,89)) AND value BETWEEN 10.00 AND 30000.0))) OR (unit IN ('microsievert','usv') AND value BETWEEN 0.02 AND 5.0)) AND (ST_X(location::geometry) != 0.0 OR ST_Y(location::geometry) != 0.0) AND ST_Y(location::geometry) BETWEEN -85.05 AND 85.05 AND ST_X(location::geometry) BETWEEN -180.00 AND 180.00 AND (user_id != 671 OR value < 38.5 OR ST_Y(location::geometry) NOT BETWEEN 35.4489 AND 50.0516 OR ST_X(location::geometry) NOT BETWEEN 12.8861 AND 14.4561 OR captured_at < TIMESTAMP '2015-06-25 00:00:00' OR captured_at > TIMESTAMP '2015-07-14 23:59:59') AND (user_id NOT IN (9,442) OR value < 35.0 OR ST_Y(location::geometry) NOT BETWEEN  35.4489 AND  35.7278 OR ST_X(location::geometry) NOT BETWEEN 139.5706 AND 139.9186) AND (user_id != 366 OR value <  35.0 OR ST_Y(location::geometry) NOT BETWEEN -45.5201 AND -7.6228 OR ST_X(location::geometry) NOT BETWEEN 111.3241 AND 153.8620 OR (value < 105.0 AND ST_X(location::geometry) < 111.3241))) to '/tmp/mclean.csv' csv
