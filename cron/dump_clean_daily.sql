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
     AND captured_at IS NOT NULL) ;

\copy (SELECT * FROM dump_clean_daily) TO 'dump_clean_daily.csv' HEADER CSV
COMMIT;


DROP VIEW dump_clean_daily;
