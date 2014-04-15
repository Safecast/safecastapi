SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- =============================================================================================
-- ABSTRACT:
-- =============================================================================================
--
-- ios_query.sql: Primary PostgreSQL query to export measurements for the iOS app update.
--
--                This performs the following actions:
--                     1. Change detection
--                     2. Filters out bad data
--                        a. Sanity filtering
--                        b. Blacklists
--                     3. Reprojects EPSG:4326 -> EPSG:3857 (lat/lon to web Mercator pixel x/y)
--                     4. Converts CPM to uSv/h
--                     5. Bins / clusters data points at ~19m resolution
--                     6. Creates temporary X/Y/Z CSV for export
--
--                 The CSV in #6 is converted into a SQLite 3 binary database for client DL
--                 with a later shell script, to provide integrity checks and faster processing.


-- =============================================================================================
-- ATTENTION!!
-- =============================================================================================
-- THIS IS USED BY A PRIMARY PRODUCTION APPLICATION.
-- 
-- MODIFICATION CAN RESULT IN IOS APP DATA UPDATES BEING CORRUPT, INOPERABLE, OR SERVER LOAD
-- THAT BLOCKS OTHER PROCESSES INCLUDING ALL SAFECAST API FUNCTIONS.
--
-- PLEASE COMMUNICATE AND COMMENT ANY CHANGES MADE.



-- =============================================================================================
-- SERVER / PERMISSION REQUIREMENTS
-- =============================================================================================
-- Table "measruements":  SELECT
-- Table "iOSLastUpdate": CREATE, INSERT, UPDATE, DELETE, SELECT
-- Temporary tables:      CREATE, INSERT, UPDATE, DELETE, SELECT
-- File System:           READ, WRITE, CREATE, DELETE (CSV)



-- =============================================================================================
-- SERVER RESOURCE USE:
-- =============================================================================================
-- - Row/table locking:
--   - iOSLastUpdate: minor, no other processes use.
--
-- - Schema locking:
--   - None.
--
-- - Change detection:
--   - While a single-row permanent table is maintained by this script on the server for tracking 
--     changes, it does not require this to function or expect that it necessarily exists.
--   - As of 2014-04-15 change detection is made mostly inoperable by test data submssions.
--
-- - Runtime
--   - As of 2014-04-15 this takes ~15 mins to run on Cloud 66.
--
-- - CPU, I/O
--   - Significant CPU resources are used, but not enough to block other processes.
--   - Several GB in temp tables and VM are required.
--   - Be advised this can increase rapidly if you change this script; subtle changes can
--     create significant server load.



-- =============================================================================================
-- MAINTENANCE REQUIREMENTS:
-- =============================================================================================
-- - Filtering bad data:
--   - If points are not removed from the database, they should be blacklisted by the primary key
--     ID or another indexed integer column.
--   - Blacklists should be avoided if possible.
-- - Dose rate conversion:
--   - Any new device submitting measurements in CPM must have a gamma sensitivity manually hardcoded
--     below due to database schema limitations not including this information.
--   - This should not be done for test devices or devices that do not primarily measure gamma radiation.
--   - Note a device_id of NULL is assumed to be a bGeigie with a LND7317 sensor.




BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS iOSLastExport(LastMaxID INT, ExportDate TIMESTAMP);
COMMIT TRANSACTION;

-- performance note: Temp1 is created with as limited of width data types as possible, for example
--                   32-bit floats and 16-bit date integers.  While the numerics time on the CPU
--                   is not affected, this produces a 2x-5x increase in query performance due to less
--                   disk IO and more efficient composite b-tree indexing.

BEGIN TRANSACTION;
CREATE TEMPORARY TABLE IF NOT EXISTS Temp1(X1 INT, Y1 INT, captured_at INT2, DRE FLOAT4);
TRUNCATE TABLE Temp1;

-- coordinate system note: Coordinate system reprojection and magic numbers are derived from:
--                         http://msdn.microsoft.com/en-us/library/bb259689.aspx
--                         These values are specific to web Mercator EPSG 3857 zoom level 13.
--                         For other zoom levels you must change these values.
--                         The value is hardcoded rather than calculated to increase performance.
--                         DO NOT CHANGE THE ZOOM LEVEL ON THE PRODUCTION IOS APP.


-- ==============================================================================================================
-- PRIMARY DATA QUERY
-- ==============================================================================================================

-- first insert is for NON Japan Post (ie, normal) data
-- also filters the user QuartaRad (345) who repeatedly submits bad data
-- temp ban on user_id=366 (Brian Jones) until backend delete is fixed or someone identifies points manually
--      verify with: https://api.safecast.org/en-US/measurements?utf8=%E2%9C%93&latitude=-26.9918&longitude=137.3043&distance=10000&captured_after=&captured_before=&since=&until=&commit=Filter
-- uSv/h upper limit 75 -> 5 to correct for users submitting web measurements in CPM
INSERT INTO Temp1(X1, Y1, captured_at, DRE)
SELECT CAST((ST_X(location::geometry)+180.0)/360.0*2097152.0+0.5 AS INT) AS X1
    ,CAST((0.5-LN((1.0+SIN(ST_Y(location::geometry)*pi()/180.0))/(1.0-SIN(ST_Y(location::geometry)*pi()/180.0)))/(4.0*pi()))*2097152.0+0.5 AS INT) AS Y1
    ,CAST(EXTRACT(epoch FROM captured_at)/86400 AS INT2) AS captured_at
    ,CASE
        WHEN unit='cpm' AND device_id IS NULL THEN value/350.0
        WHEN unit IN ('microsievert','usv') THEN value
        WHEN unit='cpm' AND device_id IN (5,15,16,17,18,22) THEN value/350.0
        WHEN unit='cpm' AND device_id IN (6,7,11,13,23) THEN value/100.0
        WHEN unit='cpm' AND device_id IN (4,9,10,12,19,24) THEN value/132.0
        WHEN unit='cpm' AND device_id IN (21) THEN value/1750.0
        ELSE 0.0
    END AS DRE
FROM measurements
WHERE (SELECT MAX(id) FROM measurements) > COALESCE((SELECT MAX(LastMaxID) FROM iOSLastExport),0)
    AND user_id NOT IN (345,347,366)
    AND (id < 23181608 OR id > 23182462) -- 100% bad
    AND (id < 20798302 OR id > 20803607) -- 20% bad, but better filtering too slow
    AND (id < 21977826 OR id > 21979768) -- 100% bad
    AND (id < 24060795 OR id > 24067649) -- invalidated, raining, most 2x normal
    AND id NOT IN (13194822,15768545,15768817,15690104,15768346,15768782,15768792,16381794,18001818,17342620,14669786,25389168,25389158,25389157,25389153,24482487,16537265,16537266,19554057,19554058,19554059,19554060,19555677,19589301,19589302,19589303,19589304,19589305,19589303,19589304,19589305,19600634,19699406,17461603,17461607,17461611,17461615,16981355,16240105,16240101,16240097,16240093,16241392,16241388,18001769,25702033,25702031)
    AND id NOT IN (14764408,14764409,14764410,14764411,14764412,14764413,13872611,13872612,14764388,14764389,14764390,14764391,14764392,14764393,14764394,14764395,14764396,14764397,14764398,14764399,14764400,14764401,14764402,14764403,14764404,14764405,14764406,14764407) -- bad streak in hot area
    AND captured_at > TIMESTAMP '2011-03-01 00:00:00'
    AND captured_at < localtimestamp + interval '48 hours'
    AND captured_at IS NOT NULL
    AND (  (unit='cpm' AND value IS NOT NULL AND value > 10.0 AND ( (device_id IS NULL AND value < 350000.0) OR (device_id <= 24 AND value < 30000.0) ))
        OR (unit IN ('microsievert','usv') AND value IS NOT NULL AND value > 0.02 AND value < 5.0))
    AND location IS NOT NULL
    AND (  ST_X(location::geometry) != 0.0
        OR ST_Y(location::geometry) != 0.0)
    AND ST_Y(location::geometry) < 85.05
    AND ST_Y(location::geometry) > -85.05
    AND ST_X(location::geometry) >= -180.0
    AND ST_X(location::geometry) <=  180.0;
COMMIT TRANSACTION;

-- ==============================================================================================================
-- JAPAN POST WORKAORUND SELECT
-- ==============================================================================================================
-- This 2nd insert is a hack workaround for JP post data
-- it partially corrects the spatial error by approximating the centroid from the original trunc in the firmware
-- -10k to the "days since 1970" is approx a -30 year penalty to the date restrictive binning so as not to
--       contaminate measurements with superior spatial resolution
BEGIN TRANSACTION;
INSERT INTO Temp1(X1, Y1, captured_at, DRE)
SELECT CAST((CAST(ST_X(location::geometry) AS FLOAT)+180.0)/360.0*2097152.0+0.5 AS INT)+2 AS X1
    ,CAST((0.5-LN((1.0+SIN(CAST(ST_Y(location::geometry) AS FLOAT)*pi()/180.0))/(1.0-SIN(CAST(ST_Y(location::geometry) AS FLOAT)*pi()/180.0)))/(4.0*pi()))*2097152.0+0.5 AS INT)-2 AS Y1
    ,CAST(EXTRACT(epoch FROM captured_at)/86400 AS INT2)-10950 AS captured_at
    ,CASE
        WHEN unit='cpm' AND device_id IS NULL THEN value/350.0
        WHEN unit IN ('microsievert','usv') THEN value
        WHEN unit='cpm' AND device_id IN (5,15,16,17,18,22) THEN value/350.0
        WHEN unit='cpm' AND device_id IN (6,7,11,13,23) THEN value/100.0
        WHEN unit='cpm' AND device_id IN (4,9,10,12,19,24) THEN value/132.0
        WHEN unit='cpm' AND device_id IN (21) THEN value/1750.0
        ELSE 0.0
    END AS DRE
FROM measurements
WHERE (SELECT COUNT(*) FROM Temp1) > 0 -- in case new rows get added to measurements between insert blocks
    AND (SELECT MAX(id) FROM measurements) > COALESCE((SELECT MAX(LastMaxID) FROM iOSLastExport),0)
    AND user_id = 347
    AND captured_at > TIMESTAMP '2011-03-01 00:00:00'
    AND captured_at < localtimestamp + interval '48 hours'
    AND captured_at IS NOT NULL
    AND (  (unit='cpm' AND value IS NOT NULL AND value > 10.0 AND ( (device_id IS NULL AND value < 350000.0) OR (device_id <= 24 AND value < 30000.0) ))
        OR (unit IN ('microsievert','usv') AND value IS NOT NULL AND value > 0.02 AND value < 5.0))
    AND location IS NOT NULL
    AND (  ST_X(location::geometry) != 0.0
        OR ST_Y(location::geometry) != 0.0)
    AND ST_Y(location::geometry) < 85.05
    AND ST_Y(location::geometry) > -85.05
    AND ST_X(location::geometry) >= -180.0
    AND ST_X(location::geometry) <=  180.0;
COMMIT TRANSACTION;

BEGIN TRANSACTION;
CREATE INDEX idx_Temp1_X1Y1CD ON Temp1(X1,Y1,captured_at);
COMMIT TRANSACTION;

-- clamp to bounds of projection (shouldn't ever be hit, but...)
BEGIN TRANSACTION;
UPDATE Temp1 SET X1=0 WHERE X1<0;
UPDATE Temp1 SET X1=2097151 WHERE X1>2097151;
UPDATE Temp1 SET Y1=0 WHERE Y1<0;
UPDATE Temp1 SET Y1=2097151 WHERE Y1>2097151;
COMMIT TRANSACTION;

-- ==============================================================================================================
-- POINT GRIDDING / AGGREGATION / BINNING
-- ==============================================================================================================
-- This clusters the data points into a 19m grid simply by (efficient) virtue of integer truncation.
--
-- Spatial indexing and/or OGC geometry/geography types are not necessary for this.
--
-- Date/Time Column:
-- - "T" column: this is "days since 1970".
-- - It is used to select only the latest 270 days of measurements for any given point.
-- - This helps present a more "recent" view of data without culling massive amounts in a crude WHERE.
-- - 270 days is completely arbitrary.
--
-- Performance Advisory:
--   - The indexing in gridding so many millions of points is extremely sensitive to data type widths.
--   - Using 64-bit types for these columns will make this at least an order of magtniude slower.
--   - You have been warned.

BEGIN TRANSACTION;
CREATE TEMPORARY TABLE IF NOT EXISTS Temp2(X INT,Y INT,T INT2,Z FLOAT4);
TRUNCATE TABLE Temp2;
INSERT INTO Temp2(X,Y,T) SELECT X1,Y1,MAX(captured_at)-270 FROM Temp1 GROUP BY X1,Y1;
COMMIT TRANSACTION;

BEGIN TRANSACTION;
UPDATE Temp2 SET Z = (SELECT AVG(DRE) FROM Temp1 WHERE X1=X AND Y1=Y AND captured_at > T);
DROP TABLE Temp1;
COMMIT TRANSACTION;

-- old ORDER BY: ORDER BY Y/256*8192+X/256

-- ==============================================================================================================
-- BINARY DATA STRUCTURE CLUSTERING
-- ==============================================================================================================
-- The very long and very ugly hardcoded ORDER BY is a good thing.
-- 
-- Modeled after Microsoft's "QuadKey", this is a SQL implementation that clusters and orders data such that all
-- pixels for a tile will be contiguous.
--
-- By "recursive", it means that if processing and tiling is done synchronously, the entire process can use
-- aligned, sequential binary reads for maximum IO throughput and low CPU overhead.
-- 
-- This is why the iOS app can rasterize data in 2 minutes while gdal_rastersize takes over 24 hours for the
-- exact same dataset.
--
-- It is like the difference between Doom and povray.
-- It is the only reason the iOS app can update data at all.
-- 
-- iOS app 1.6.9 depends on recursive clustering; that is, it uses direct reads in row-order at each pyramid level.

-- iOS app 1.7.0+ only absolutely depends on z=13 being clustered, however recursive clustering still likely
-- is of benefit to performance nonetheless.  The change is 1.7.0+ uses asynchronous multithreaded
-- processing while tiling and thus must sort/cluster on its end.  This is somewhat slower, but offset by the
-- multithreaded performance.
--
-- The underlying math is trivial to derive.  See the MSDN Bing Maps Tile System article linked above.

-- 16-bit output: iOS client 1.6.9 
\copy (SELECT X,Y,CASE WHEN Z > 65.535 THEN 65535 ELSE CAST(Z*1000.0 AS INT) END AS Z FROM Temp2 ORDER BY Y/256/4096*2+X/256/4096,Y/256/2048*4+X/256/2048,Y/256/1024*8+X/256/1024,Y/256/512*16+X/256/512,Y/256/256*32+X/256/256,Y/256/128*64+X/256/128,Y/256/64*128+X/256/64,Y/256/32*256+X/256/32,Y/256/16*512+X/256/16,Y/256/8*1024+X/256/8,Y/256/4*2048+X/256/4,Y/256/2*4096+X/256/2,Y/256*8192+X/256) to '/tmp/ios13.csv' csv

-- 32-bit output: iOS client 1.7.0
\copy (SELECT X,Y,CAST(Z*1000.0 AS INT) FROM Temp2 ORDER BY Y/256/4096*2+X/256/4096,Y/256/2048*4+X/256/2048,Y/256/1024*8+X/256/1024,Y/256/512*16+X/256/512,Y/256/256*32+X/256/256,Y/256/128*64+X/256/128,Y/256/64*128+X/256/64,Y/256/32*256+X/256/32,Y/256/16*512+X/256/16,Y/256/8*1024+X/256/8,Y/256/4*2048+X/256/4,Y/256/2*4096+X/256/2,Y/256*8192+X/256) to '/tmp/ios13_32.csv' csv



BEGIN TRANSACTION;
DELETE FROM iOSLastExport 
WHERE (SELECT COUNT(*) FROM Temp2) > 0 -- in case rows got added partway through
AND LastMaxID < (SELECT MAX(id) FROM measurements);

INSERT INTO iOSLastExport(LastMaxID,ExportDate) 
SELECT MAX(id), CURRENT_TIMESTAMP 
FROM measurements
WHERE (SELECT COUNT(*) FROM Temp2) > 0
    AND (SELECT MAX(id) FROM measurements) > COALESCE((SELECT MAX(LastMaxID) FROM iOSLastExport),0);

DELETE FROM iOSLastExport WHERE LastMaxID IS NULL OR LastMaxID = 0;
COMMIT TRANSACTION;

BEGIN TRANSACTION;
DROP TABLE Temp2;
COMMIT TRANSACTION;
