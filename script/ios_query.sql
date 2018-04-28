SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- =============================================================================================
-- UPDATE HISTORY: (SINCE 2014-10-25)
-- =============================================================================================
-- 2018-04-28 ND: Remove bad drive id 28231 per Sean.
-- 2017-02-11 ND: Remove 4x GPS error in ocean
-- 2017-02-08 ND: Misc bad data filters
-- 2016-10-10 ND: Remove manually submitted bad point, id=72588855
-- 2016-09-13 ND: Add filters for NYC Manhattan hot streak, drive id 21383
-- 2016-09-09 ND: Add filters for many GPS errors
-- 2016-06-01 ND: Add filter for id=55846508,55846405,55846384
-- 2016-06-01 ND: Add filter for 44 rows with bad dates from 2016-06-11 - 2021-06-01
-- 2016-06-01 ND: Add filter for id=63347043
-- 2016-05-31 ND: bGeigie conversion /350.0 -> /334.0 per Pieter.
-- 2016-05-31 ND: Add filter for user_id=1032
-- 2016-05-29 ND: Add filters for id=63242347, user_id=902
-- 2016-04-18 ND: Add filter for cosmic radiation data subtype (actually non-unknown, non-drive subtypes)
-- 2016-03-15 ND: Add filter for bad drive id 21887 per Sean/Azby/Joe.
-- 2015-12-30 ND: Add filter for bad drive id 21112.
-- 2015-12-13 ND: Add filter for bad drive id 19900 per Azby.
-- 2015-09-13 ND: Add filter for bad drive id 19980 per Azby.
-- 2015-07-15 ND: Add filter for bad/deleted drive orphan points in .cz (user_id = 671)
--                Removed load balancing hack added on 2015-03-31.
-- 2015-03-31 ND: Add 1.0DD deadzone around (0, 0) because GPS chipset firmware is hard.
--                (was: test for 0.0 exactly with no epsilon)
-- 2015-03-30 ND: Add temp hack to disable use of the "last export" table due to issues with new
--                load balancing and two servers.  Should be removed when the DB job is
--                coalesced to a single server and copied to the others.
-- 2014-10-25 ND: Added support for device_id 69 and 89.  Manually filtered some bad test points
--                for user_id 531, 541.  Did not see any other valid devices to add gamma
--                sensitivities for that were in-use, other than static sensors.

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
--   - CREATE TABLE iOSLastUpdate (once ever per server)
--   - CREATE TABLE <various #temp tables>
--   - CREATE INDEX <various #temp indices on #temp tables>
--   - DROP TABLE <various #temp tables>
--
-- - Change detection:
--   - While a single-row permanent table is maintained by this script on the server for tracking 
--     changes, it does not require this to function or expect that it necessarily exists.
--   - As of 2014-04-15 change detection is made mostly inoperable by test data submssions.
--
-- - Runtime
--   - As of 2014-04-16 this takes ~7 mins to run on Cloud 66.
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
COMMIT TRANSACTION;

-- ======================================================
-- COORDINATE SYSTEM REPROJECTION
-- ======================================================
-- Coordinate system reprojection and magic numbers are derived from:
--      http://msdn.microsoft.com/en-us/library/bb259689.aspx
--
--      These values are specific to Web Mercator EPSG 3857 zoom level 13.
--      For other zoom levels you must change these values.
--
--      Reprojection "magic numbers" are hardcoded into
--      the main query with collapsed expressions and
--      reciprocal estimates for performance.
--
--      DO NOT CHANGE THE ZOOM LEVEL ON THE PRODUCTION IOS APP.


-- ======================================================
-- GAMMA SENSITIVITY REFERENCE INFORMATION
-- ======================================================
-- This reflects information hardcoded below in the SELECT statements.
-- 
-- CPM is multiplied by the reciprocal estimate, instead of dividing.
-- This provides a minor performance gain.
--
--         device_id  uSvh=CPM/x      Reciprocal Estimate
-- =================  ==========     ====================
--              NULL       334.0       0.0029940119760479  Per Pieter
--5,15,16,17,18,22,69,89   350.0       0.0028571428571429
--      6,7,11,13,23       100.0                     0.01
--   4,9,10,12,19,24       132.0       0.0075757575757576
--                21      1750.0    0.0005714285714285714
--  21 & user_id=530     11000.0    0.0000909090909090909  *** TEMPORARY ***




-- ==============================================================================================================
-- PRIMARY DATA QUERY
-- ==============================================================================================================

-- User filtering now specific to area and value to reduce collateral damage.

-- User Blacklists/Filtering       Details
-- =========================       ===========================================================================
-- - user_id =   9 (Rob)         - Test data.        Filter: Tokyo extent only, > 0.10 uSv/h only.
-- - user_id = 345 (QuartaRad)   - All data (user submitted only bad data)
-- - user_id = 366 (Brain Jones) - Aircraft flight.  Filter:   .au extent only, > 0.30 uSv/h only.
--    user_id= 366 check: https://api.safecast.org/en-US/measurements?utf8=%E2%9C%93&latitude=-26.9918&longitude=137.3043&distance=10000&captured_after=&captured_before=&since=&until=&commit=Filter
-- - user_id = 442 (?)           - Test data.        Filter: Tokyo extent only, > 0.10 uSv/h only.
-- - user_id = 530 (Ferez Yvan)  - Device was more sensitive than device_id=21, due to static device_id list in iOS app
--                                     converting these specifically until new device_id set up later and
--                                     dynamic device_id selection in iOS app is implemented.
-- - user_id = 902 (Mickael)     - Appears to submit 100% bad data.
-- - user_id = 1032 (Johan)      - Appears to submit 100% bad data.
-- - user_id = 1225 (Dayton)     - Appears to submit 100% bad data.


-- Value Blacklists/Filtering      Details
-- ==========================      ============================================================================
-- - unit = 'usv'                  Max of 5.0 uSv/h sanity filter due to repeated bad data entry on web form / human error.

-- Japan Post (347) Workarounds    Details
-- ============================    ============================================================================
-- - Centroid offset               Projected x/y +2 and -2, respectively.  This is because JP Post units truncate to nearest ~100m lat/lon.
--                                     Shifting the point to the approximate centroid reduces the error.
--                                     (2px @ 19m = 38m, the closest integer value to 50m without exceeding it)
-- - Binning penalty               Lower spatial resolution, so given a penalty of two years when binning.
--                                     This means JP Post will only take precedent over the oldest measurements.

-- New ID-based Blacklists         Details
-- =============================   ============================================================================
-- 33708769, 33708779, 33709181,   2014-10-25 ND: specific filtering for a couple points by user_id 531 in .au.
-- 33709199, 33709164
-- 39366523, 39417687              2014-10-25 ND: filter test data from user_id 541 to add new device_id of 89.
-- 48825707--48821163              2015-07-15 ND: filter bad .cz drive data submission
-- 63242347                        2016-05-29 ND: filter bad single point from bGeigie log
-- 63347043                        2016-06-01 ND: filter bad single point manual / direct API submission
-- 55846508,55846405,55846384      2016-06-01 ND: filter for 3x bad points in .in
-- *                               2016-09-09 ND: misc filtering, listed inline in comments below
-- 57830339, *                     2016-09-13 ND: filter for .us/NYC,NY/Manhattan hot streak
-- 47531878--47532148              2017-02-08 ND: filter bad .hk GPS in ocean

BEGIN TRANSACTION;

INSERT INTO Temp1(X1, Y1, captured_at, DRE)
SELECT CAST( 
              (ST_X(location::geometry) + 180.0) * 5825.422222222222 + 0.5 
            AS INT
           )
       + (CASE WHEN (user_id = 347) THEN 2 ELSE 0 END) -- JP Post: correct offset to centroid vs. WGS84 trunc
       AS X1
    ,CAST(
            (0.5 - LN(  (1.0 + SIN(ST_Y(location::geometry) * 0.0174532925199433))
                      / (1.0 - SIN(ST_Y(location::geometry) * 0.0174532925199433)))
                   * 0.0795774715459477
            ) * 2097152.0 + 0.5 
          AS INT
         )
     + (CASE WHEN (user_id = 347) THEN -2 ELSE 0 END) -- JP Post: correct offset to centroid vs. WGS84 trunc
     AS Y1
    ,CAST( 
            EXTRACT(epoch FROM captured_at) / 86400 
          AS INT2
         )
     + (CASE WHEN (user_id = 347) THEN -730 ELSE 0 END) -- JP Post: penalty during binning due to low spatial rez
     AS captured_at
    ,CASE
        WHEN unit='cpm' AND device_id IS NULL                     THEN value * 0.0029940119760479
        WHEN unit IN ('microsievert','usv')                       THEN value
        WHEN unit='cpm' AND device_id IN (5,15,16,17,18,22,69,89) THEN value * 0.0028571428571429
        WHEN unit='cpm' AND device_id IN (6,7,11,13,23)           THEN value * 0.01
        WHEN unit='cpm' AND device_id IN (4,9,10,12,19,24)        THEN value * 0.0075757575757576
        WHEN unit='cpm' AND device_id=21 AND user_id=530          THEN value * 0.0000909090909090909 -- *** TEMPORARY ***
        WHEN unit='cpm' AND device_id IN (21)                     THEN value * 0.0005714285714285714
        ELSE 0.0
    END 
    AS DRE
FROM measurements
WHERE (SELECT MAX(id) FROM measurements) > COALESCE((SELECT MAX(LastMaxID) FROM iOSLastExport),0)
    AND (   measurement_import_id NOT IN (SELECT id FROM measurement_imports WHERE subtype NOT IN ('None', 'Drive'))
         OR measurement_import_id IS NULL)
    AND id NOT BETWEEN 23181608 AND 23182462 -- 100% bad
    AND id NOT BETWEEN 20798302 AND 20803607 -- 20% bad, but better filtering too slow
    AND id NOT BETWEEN 21977826 AND 21979768 -- 100% bad
    AND id NOT BETWEEN 24060795 AND 24067649 -- invalidated, raining, most 2x normal
    AND id NOT IN (13194822,15768545,15768817,15690104,15768346,15768782,15768792,16381794,18001818,17342620,14669786,25389168,25389158,25389157,25389153,24482487,16537265,16537266,19554057,19554058,19554059,19554060,19555677,19589301,19589302,19589303,19589304,19589305,19589303,19589304,19589305,19600634,19699406,17461603,17461607,17461611,17461615,16981355,16240105,16240101,16240097,16240093,16241392,16241388,18001769,25702033,25702031,72588855)
    AND id NOT IN (14764408,14764409,14764410,14764411,14764412,14764413,13872611,13872612,14764388,14764389,14764390,14764391,14764392,14764393,14764394,14764395,14764396,14764397,14764398,14764399,14764400,14764401,14764402,14764403,14764404,14764405,14764406,14764407) -- bad streak in hot area
    AND id NOT IN (33708769,33708779,33709181,33709199,33709164,39366523,39417687,63242347,63347043,55846508,55846405,55846384)
    AND id NOT IN (40660074, 40660076, 60030299, 60030298, 60030297, 60030296, 24836479, 24836480, 24836482, 24836481, 24836485, 24836483, 24836484, 40790198, 40790201, 40790203, 14864065, 14880942, 14885129, 14801612, 14864081, 14880681, 14880718, 14880838, 14880927, 14880975, 14885086, 14885150, 14885165, 14885185, 15084125, 15084258, 15100856, 15768545, 15768826, 15821550, 40660078, 40660079, 56193501, 56193500, 56193499, 56193498, 56193497, 56193496) -- bad dates 2016-06-11 to 2021-06-01
    AND id NOT BETWEEN 48821163 AND 48825707 -- bad .cz drive data
    AND id NOT BETWEEN 51725281 AND 51730948 -- bad .fr drive data bgeigie_import_id=19980
    AND id NOT BETWEEN 54522618 AND 54523174 -- bad .ua drive data bgeigie_import_id=20582
    AND id NOT BETWEEN 55671785 AND 55676469 -- bad .fr drive data bgeigie_import_id=20900
    AND id NOT BETWEEN 56496499 AND 56499124 -- bad .jp flight data bgeigie_import_id=21112
    AND id NOT BETWEEN 59724187 AND 59724235 -- bad .us test data bgeigie_import_id=21887
    AND id NOT IN (66684139,69542903) -- Misc GPS error that wound up near (0,0)
    AND id NOT IN (70555855,70555854,70555853,70555852,70555851,70555850,70555849,70555848,70555847,70555846,70555845,70555844,70555813,70555812,70555811,70555810,70555809,70555808,70555807,70555806,70555805,70555804,70555803,70555802,70555353,70555352,70555351,70555350,70555349,70555348,70555347,70555346,70555345,70555344,70555343,70555342,70555341,70554461,70554460,70554459,70554458,70554457,70554456,70554455,70554454,70554453,70554452,70554451,70554450,70554449) -- Boston MA US, log=20676
    AND id NOT IN (66071904,70321927,70321926,70321925,70321924,70321923,70321922,70321921,70321920,70321919,70321918,70321975,70321974) -- Boston MA US, log=20677
    AND id NOT BETWEEN 42741132 AND 42743148 -- GPS error Austin TX US, log=17671
    AND id NOT BETWEEN 26158517 AND 26158723 -- GPS error Fukushima coast JP, log=13690
    AND id NOT BETWEEN 26157859 AND 26158516 -- GPS error Fukushima coast JP, log=13690
    AND id NOT BETWEEN 54806156 AND 54806236 -- GPS error Boston MA coast US, log=20681
    AND id NOT BETWEEN 39712555 AND 39713449 -- GPS error Boston MA coast US, log=16798
    AND id NOT BETWEEN 36736478 AND 36736489 -- GPS error Montana US, log=15775
    AND id NOT BETWEEN 42129750 AND 42129806 -- GPS error Honshu coast JP, log=17539
    AND (id NOT BETWEEN 28484658 AND 29430580 OR user_id != 9) -- GPS error Honshu coast JP, no log id
    AND id NOT IN (17573243,17573245,17573249,17573252,17573254,17573256,17573258,17573262,17573265,17573268,17573271,17573274,17573278,17573281,17573284,17573287,17573290,17573292,17573294,17573296,17573299,17573303,17573307,17573310,17573313,17573316,17573319,17573323,17573327,17573329,17573332,17573335,17573338,17573341,17573345,17573348,17573350,17573352,17573355,17573358,17573363,17573367,17573370,17573372,17573376,17573379,17573382,17573385,17573388,17573392,17573395,17573399,17573401,17573404,17573407,17573410,17573413,17573417,17573420,17573423,17573426,17573429,17573432,17573435,17573438,17573441,17573444,17573447,17573450,17573453,17573456,17573459,17573462,17573465,17573468,17573472,17573475,17573478,17573481,17573484,17573487,17573491,17573495,17573499,17573503,17573507,17573512,17573516,17573520,17573524,17573528,17573532,17573536,17573540,17573544,17573548,17573552,17573556,17573560,17573564,17573569,17573573)
    -- above long line: GPS error Tokyo Bay JP, log=11356
    AND id NOT IN (57830339,57830338,57830337,57830336,57830335,57830334,57830332,57830330,57830329,57830326,57830324,57830322) -- hot streak Manhattan, NYC, NY US
    AND id NOT IN (43199883,43199875,75302533,43200647,66567253,66569229,66567254,66569231,66080351,72588855,77757657,77757750,68466104,68466223,68466103,68466103)
    AND id NOT BETWEEN 47531878 AND 47532148
    AND id NOT BETWEEN 17682519 AND 17682905
    AND id NOT BETWEEN 110904809 AND 110905092 -- removed .ir drive data bgeigie_import_id=28231
    AND user_id NOT IN (345,902,1032,1225,106)--347
    AND captured_at > TIMESTAMP '2011-03-01 00:00:00'
    AND captured_at < localtimestamp + interval '48 hours'
    AND captured_at IS NOT NULL
    AND value       IS NOT NULL
    AND location    IS NOT NULL
    AND (   (unit  = 'cpm' AND (   (    device_id IS NULL     AND value BETWEEN 10.00 AND 350000.0) 
                                OR ((   device_id <= 24 
                                     OR device_id IN (69,89)) AND value BETWEEN 10.00 AND  30000.0)))
         OR (unit IN ('microsievert','usv')                   AND value BETWEEN  0.02 AND      5.0))
    AND (   ST_X(location::geometry) >  1.0
         OR ST_X(location::geometry) < -1.0
         OR ST_Y(location::geometry) >  1.0
         OR ST_Y(location::geometry) < -1.0)
    AND ST_Y(location::geometry) BETWEEN  -85.05 AND  85.05
    AND ST_X(location::geometry) BETWEEN -180.00 AND 180.00
    AND (   user_id NOT IN (9,442)                                      -- filter, specific to area and measurement value
         OR value        < 35.0                                         -- 0.10 uSv/h
         OR ST_Y(location::geometry) NOT BETWEEN  35.4489 AND  35.7278  -- not in tokyo extent
         OR ST_X(location::geometry) NOT BETWEEN 139.5706 AND 139.9186)
    AND (   user_id != 366                                              -- filter, specific to area and measurement value
         OR value    <  35.0                                            -- 0.10 uSv/h
         OR ST_Y(location::geometry) NOT BETWEEN -45.5201 AND  -7.6228  -- not in .au extent
         OR ST_X(location::geometry) NOT BETWEEN 111.3241 AND 153.8620
         OR (value < 105.0 AND ST_X(location::geometry) < 111.3241)   );-- western .au coast only - slightly higher max
COMMIT TRANSACTION;




BEGIN TRANSACTION;
     CREATE INDEX idx_Temp1_X1Y1CD ON Temp1(X1,Y1,captured_at);
COMMIT TRANSACTION;

-- clamp to bounds of projection (shouldn't ever be hit, but...)
BEGIN TRANSACTION;
     UPDATE Temp1 SET X1 =       0 WHERE X1 <       0;
     UPDATE Temp1 SET X1 = 2097151 WHERE X1 > 2097151;
     UPDATE Temp1 SET Y1 =       0 WHERE Y1 <       0;
     UPDATE Temp1 SET Y1 = 2097151 WHERE Y1 > 2097151;
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

     INSERT INTO Temp2(X,Y,T) 
     SELECT X1
           ,Y1
           ,MAX(captured_at) - 270 
     FROM Temp1 
     GROUP BY X1,Y1;

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
-- ==============================================================================================================
-- MOAR INFO:
-- ==============================================================================================================
--
-- The underlying math is as follows:
--   ORDER BY ((Y>>20)<<1)+(X>>20) ... , ... ((Y>>8)<<13)+(X>>8)
--
-- These bitshift expressions are a collapsed form of the following:
--
--            [A]  [B]  [C]     [A]  [B]
--            === ====  ===     === ====
-- Z= 1:    Y/256/4096*   2 + X/256/4096,
-- Z= 2:    Y/256/2048*   4 + X/256/2048,
-- Z= 3:    Y/256/1024*   8 + X/256/1024,
-- Z= 4:    Y/256/ 512*  16 + X/256/ 512,
-- Z= 5:    Y/256/ 256*  32 + X/256/ 256,
-- Z= 6:    Y/256/ 128*  64 + X/256/ 128,
-- Z= 7:    Y/256/  64* 128 + X/256/  64,
-- Z= 8:    Y/256/  32* 256 + X/256/  32,
-- Z= 9:    Y/256/  16* 512 + X/256/  16,
-- Z=10:    Y/256/   8*1024 + X/256/   8,
-- Z=11:    Y/256/   4*2048 + X/256/   4,
-- Z=12:    Y/256/   2*4096 + X/256/   2,
-- Z=13:    Y/256     *8192 + X/256
--          ---------------   ----------
--           [Y-axis index]   [X-axis index]
-- 
-- What is going on here:
-- 1. [A]: Pixel X/Y is converted to tile X/Y, by dividing the pixel X/Y by 256 (as each tile is 256x256 pixels)
-- 2. [B]: The number of tiles spanning the world, width or height, is then converted to a previous zoom level for clustering.
--         i.   Zoom level 13 has 8192 tiles width or height.  (2^13)
--         ii.  Zoom level  1 has    2 tiles width or height.  (2^ 1)
--         iii. Thus, scaling is /x, where x is 2^(Zsrc-Zdest).
--         iv.  Above, that is /x, where x = 2^(13-1), or /(2^12), or /4096.
-- 3. [C]: The X/Y coordinates are converted to a single tile index by using row ordering, similar to how pixels in a monochrome image
--         are accessed and addressed.
--
-- In summary, the core principles:
-- 1. Use normal, traditional image pixel addressing conventions to reference each tile at a particular zoom level with unique single integer index.
--     - eg: "imageBuffer[y * numRows + x] = 255;"
-- 2. To make this recursive, scale to each zoom level from 1 to the actual resolution, in ascending order.
--
--
-- Future Clustering Improvements - 17% Theoretical Improvement
-- ============================================================
--
-- Currently the pixel x/y are 32-bit integers.  This will likely not change in the near future.
-- However, it is possible to be more efficient than this, by describing the tile and pixel indices separately.
--
-- For example, the tile (3,2) at zoom level 4 (world size 4x4 tiles) can be described as the index y*width+x, or 7.
-- Then, any specific pixel in that tile can be addressed using a 16-bit integer, as there are only 64k pixels.
--
-- In other words, the x and y columns are replaced by:
--   - tileIdx = (py*(2^z * 256) + px) / 256
--   -   pxIdx = (py*(2^z * 256) + px) - (tileIdx * 256)
--
-- Because pxIdx is guaranteed 16-bit, tileIdx is assumed 32-bit, for a total of 48 bits, compared to 64 bits for px/py.
-- Along with the DRE column, that is 32+32+16 or 10 bytes vs. 12 bytes per row.
-- For 5.7m rows, overall that is 10.9 MB (17%) less storage used and therefore faster I/O.
--
-- Caveats:
--   - This is only true as long as the number of tiles for a zoom level is less than INT32_MAX (or UINT32_MAX with offsets).
--   - eg z=13 has 67m tiles.  z=23 has 70t tiles.  INT32_MAX is 2b.  So z=13 works; z=23 will go 64-bit and there is no benefit.
--   - Actual benefits will be less than the theoretical because of SQLite variable integer widths.
--   - The pixel index would always need to be offset for storage by -32768 as SQLite uses signed integers, not unsigned.
--
-- Of course, for very low zoom levels, px*py will always produce a single 32-bit integer.  But it will roll to 64-bit
-- at zoom level 8, and z=7 isn't high enough resolution.  (1.2km)
--
-- This also hs the advantage of being non-descructive, and the original px/py can be derived from the tile/px indices.

\copy (SELECT X,Y,CAST(Z*1000.0 AS INT) FROM Temp2 ORDER BY ((Y>>20)<<1)+(X>>20),((Y>>19)<<2)+(X>>19),((Y>>18)<<3)+(X>>18),((Y>>17)<<4)+(X>>17),((Y>>16)<<5)+(X>>16),((Y>>15)<<6)+(X>>15),((Y>>14)<<7)+(X>>14),((Y>>13)<<8)+(X>>13),((Y>>12)<<9)+(X>>12),((Y>>11)<<10)+(X>>11),((Y>>10)<<11)+(X>>10),((Y>>9)<<12)+(X>>9),((Y>>8)<<13)+(X>>8)) to '/tmp/ios13_32.csv' csv


BEGIN TRANSACTION;

     DELETE FROM iOSLastExport 
     WHERE    (SELECT COUNT(*) FROM Temp2) > 0 -- in case rows got added partway through
          AND LastMaxID                    < (SELECT MAX(id) FROM measurements);

     INSERT INTO iOSLastExport(LastMaxID,ExportDate) 
     SELECT MAX(id), CURRENT_TIMESTAMP 
     FROM measurements
     WHERE   (SELECT COUNT(*) FROM Temp2)        > 0
         AND (SELECT  MAX(id) FROM measurements) > COALESCE((SELECT MAX(LastMaxID) FROM iOSLastExport),0);

     DELETE FROM iOSLastExport 
     WHERE   LastMaxID IS NULL 
          OR LastMaxID  = 0;

COMMIT TRANSACTION;



BEGIN TRANSACTION;

     DROP TABLE Temp2;

COMMIT TRANSACTION;
