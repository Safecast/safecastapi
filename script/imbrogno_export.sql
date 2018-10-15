
-- imbrogno_export and the Query,imbrogno_export.sql, performs a filtered dump of the measurements table.
-- Because of to much data, the request of certain Cities will timeout
-- The Cities are: Uppsala, Honk Kong, Taipei, Amsterdam, Perth, Sydney, Honululu, Munich and Seoul
-- This Query will export every dataset within a 3000m radius of the City center into a csv File

--                                                                                                                                                                 Uppsala                                                              Hong Kong                                                                Taipei                                                                 Amsterdam                                                              Perth                                                              Sydney                                                              Honululu                                                                   Munich                                                                    Seoul
--\copy (
select id, user_id, captured_at, ST_Y(location::geometry), ST_X(location::geometry), value, unit, device_id from measurements where (ST_DISTANCE(ST_POINT(59.8597,17.6411)::geography,location) <=3000 OR ST_DISTANCE(ST_POINT(22.3,114.166667)::geography,location) <=3000 OR ST_DISTANCE(ST_POINT(25.033333,121.533333)::geography,location) <=3000 OR ST_DISTANCE(ST_POINT(52.370197,4.890444)::geography,location) <=3000 OR ST_DISTANCE(ST_POINT(-31.95,115.85)::geography,location) <=3000 OR ST_DISTANCE(ST_POINT(-33.85,151.2)::geography,location) <=3000 OR ST_DISTANCE(ST_POINT(21.308889,-157.826111)::geography,location) <=3000 OR ST_DISTANCE(ST_POINT(48.137222,11.575556)::geography,location) <=3000 OR ST_DISTANCE(ST_POINT(37.565654,126.978135)::geography,location) <=3000)AND captured_at >= TIMESTAMP 'yesterday' AND captured_at <= TIMESTAMP 'today' AND value IS NOT NULL	 AND location IS NOT NULL ;
--) to 'c:\test\imbrogno_export.csv' csv


