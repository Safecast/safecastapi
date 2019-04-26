SET search_path TO public,postgis;

--Berlin
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(13.408333, 52.518611)::geography, 5000)) to 'berlin_export.csv' csv
--Paris
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(2.351667, 48.856667)::geography, 5000)) to 'paris_export.csv' csv
--London
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(-0.11832, 51.50939)::geography, 5000)) to 'london_export.csv' csv
--Rome
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(12.483333, 41.883333)::geography, 5000)) to 'rome_export.csv' csv
--Tokyo
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(139.774444, 35.683889)::geography, 3500)) to 'tokyo_export.csv' csv
--Ottawa
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(-75.698444, 45.411556)::geography,8000)) to 'ottawa_export.csv' csv
--Washington D.C.
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(-77.016389, 38.904722)::geography, 5000)) to 'washington_export.csv' csv
--Buenos Aires
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(-58.381944, -34.599722)::geography, 8000)) to 'buenos_aires_export.csv' csv
--Canberra
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(149.116667, -35.3)::geography, 8000)) to 'canberra_export.csv' csv
--Beijing
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(116.383333, 39.933333)::geography, 8000)) to 'beijing_export.csv' csv
--Neu-Delhi
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(77.217222, 28.62)::geography, 8000)) to 'new_delhi_export.csv' csv
--Jakarta
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(106.828611, -6.175)::geography, 8000)) to 'jakarta_export.csv' csv
--Mexico City
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(-99.145556, 19.419444)::geography, 8000)) to 'mexico_city_export.csv' csv
--Moskau
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(37.616667, 55.75)::geography, 8000)) to 'moskau_export.csv' csv
--Capetown
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(18.416689, -33.922667)::geography, 8000)) to 'cape_town_export.csv' csv
--Riyadh
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(46.71, 24.65)::geography, 5000)) to 'riyadh_export.csv' csv
--Seoul
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(126.978135, 37.565654)::geography, 5000)) to 'seoul_export.csv' csv
--Ankara
\copy (Select AVG(value) from measurements WHERE ST_DWithin(location, ST_Point(32.85, 39.916667)::geography, 5000)) to 'ankara_export.csv' csv
--Brussels
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(4.363056, 50.843333)::geography, 5000)) to 'brussels_export.csv' csv
--Brasilia
\copy (Select value from measurements WHERE ST_DWithin(location, ST_Point(-47.85, -15.8)::geography, 5000)) to 'brasilia_export.csv' csv
