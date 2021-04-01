BEGIN;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SET search_path TO public,postgis;

create temp view imbrogno_export as
  select
    id as "ID",
    user_id as "User ID",
    captured_at as "Captured Time",
    ST_Y(location::geometry) as "Latitude",
    ST_X(location::geometry) as "Longitude",
    value as "Value",
    unit as "Unit",
    device_id as "Device ID"
  from measurements
  where
    value is not NULL and
    location is not NULL and
    (
      ST_DWithin(location, ST_Point(17.6411, 59.8597)::geography, 3000) or -- Uppsala
      ST_DWithin(location, ST_Point(114.166667, 22.3)::geography, 3000) or -- Hong Kong
      ST_DWithin(location, ST_Point(126.978135, 37.565654)::geography, 3000) or -- Seoul
      ST_DWithin(location, ST_Point(121.533333, 25.033333)::geography, 3000) or -- Taipei
      ST_DWithin(location, ST_Point(4.890444, 52.370197)::geography, 3000) or -- Amsterdam
      ST_DWithin(location, ST_Point(115.85, -31.95)::geography, 3000) or -- Perth
      ST_DWithin(location, ST_Point(151.2, -33.85)::geography, 3000) or -- Sydney
      ST_DWithin(location, ST_Point(-157.826111, 21.308889)::geography, 3000) or -- Honolulu
      ST_DWithin(location, ST_Point(11.575556, 48.137222)::geography, 3000) -- Munich
    ) AND value IS NOT NULL
;

\copy (select * from imbrogno_export) to 'imbrogno_export.csv' csv header

COMMIT;
