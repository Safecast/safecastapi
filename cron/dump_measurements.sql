BEGIN;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SET search_path TO public,postgis;

create temp view dump_measurements as
  select
    captured_at as "Captured Time",
    ST_Y(location::geometry) as "Latitude",
    ST_X(location::geometry) as "Longitude",
    value as "Value",
    unit as "Unit",
    location_name as "Location Name",
    device_id as "Device ID",
    md5sum as "MD5Sum",
    height as "Height",
    surface as "Surface",
    radiation as "Radiation",
    created_at as "Uploaded Time",
    measurement_import_id as "Loader ID"
  from measurements
  order by created_at desc
;

\copy (select * from dump_measurements) to 'measurements-out.csv' csv header

COMMIT;
