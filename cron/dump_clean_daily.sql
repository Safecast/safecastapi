BEGIN;


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


SET search_path TO PUBLIC,
                   postgis;

CREATE TEMP VIEW dump_clean_daily AS
  (SELECT id,
          user_id,
          captured_at,
          ST_Y(LOCATION::geometry),
          ST_X(LOCATION::geometry),
          value,
          unit,
          device_id
   FROM measurements
   WHERE (measurement_import_id NOT IN
            (SELECT id
             FROM measurement_imports
             WHERE subtype NOT IN ('None',
                                   'Drive'))
          OR measurement_import_id IS NULL)
     AND captured_at >= TIMESTAMP 'yesterday'
     AND captured_at < TIMESTAMP 'today'
     AND captured_at IS NOT NULL
     AND value IS NOT NULL
     AND LOCATION IS NOT NULL
     AND ((unit = 'cpm'
           AND ((device_id IS NULL
                 AND value BETWEEN 10.00 AND 350000.0)
                OR ((device_id <= 24
                     OR device_id IN (69,
                                      89))
                    AND value BETWEEN 10.00 AND 30000.0)))
          OR (unit = 'celsius'
              AND value BETWEEN -80 AND 80))
     AND (ST_X(LOCATION::geometry) != 0.0
          OR ST_Y(LOCATION::geometry) != 0.0)
     AND ST_Y(LOCATION::geometry) BETWEEN -85.05 AND 85.05
     AND ST_X(LOCATION::geometry) BETWEEN -180.00 AND 180.00
     AND (user_id NOT IN (9,
                          442)
          OR value < 35.0
          OR ST_Y(LOCATION::geometry) NOT BETWEEN 35.4489 AND 35.7278
          OR ST_X(LOCATION::geometry) NOT BETWEEN 139.5706 AND 139.9186)
     AND (user_id != 366
          OR value < 35.0
          OR ST_Y(LOCATION::geometry) NOT BETWEEN -45.5201 AND -7.6228
          OR ST_X(LOCATION::geometry) NOT BETWEEN 111.3241 AND 153.8620
          OR (value < 105.0
              AND ST_X(LOCATION::geometry) < 111.3241)) ) ;

\copy (SELECT * FROM dump_clean_daily) TO '/tmp/dump_clean_daily.csv' HEADER CSV
COMMIT;


DROP VIEW dump_clean_daily;
