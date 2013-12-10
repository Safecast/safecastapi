SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS iOSLastExport(LastMaxID INT, ExportDate TIMESTAMP);
COMMIT TRANSACTION;

BEGIN TRANSACTION;
CREATE TEMPORARY TABLE IF NOT EXISTS Temp1(X1 INT, Y1 INT, captured_at INT2, DRE FLOAT4);
TRUNCATE TABLE Temp1;

-- first insert is for NON Japan Post (ie, normal) data
-- also filters the user QuartaRad (345) who repeatedly submits bad data
-- uSv/h upper limit 75 -> 5 to correct for fucking retards submitting web measurements in CPM
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
    AND user_id NOT IN (345,347)
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
--    AND (user_id != 1
--        OR captured_at > TIMESTAMP '2011-12-31 23:59:59'
--        OR value < 35.0
--        OR ST_Y(location::geometry) NOT BETWEEN 35.0  AND 36.0
--        OR ST_X(location::geometry) NOT BETWEEN 139.4 AND 140.4); -- Tokyo recent data filter.
COMMIT TRANSACTION;

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

BEGIN TRANSACTION;
UPDATE Temp1 SET X1=0 WHERE X1<0;
UPDATE Temp1 SET X1=2097151 WHERE X1>2097151;
UPDATE Temp1 SET Y1=0 WHERE Y1<0;
UPDATE Temp1 SET Y1=2097151 WHERE Y1>2097151;
COMMIT TRANSACTION;

BEGIN TRANSACTION;
CREATE TEMPORARY TABLE IF NOT EXISTS Temp2(X INT,Y INT,T INT2,Z FLOAT4);
TRUNCATE TABLE Temp2;
INSERT INTO Temp2(X,Y,T) SELECT X1,Y1,MAX(captured_at)-270 FROM Temp1 GROUP BY X1,Y1;
COMMIT TRANSACTION;

BEGIN TRANSACTION;
UPDATE Temp2 SET Z = (SELECT AVG(DRE) FROM Temp1 WHERE X1=X AND Y1=Y AND captured_at > T);
DROP TABLE Temp1;
COMMIT TRANSACTION;

-- experimental recursive "quadkey" like data clustering ORDER BY: Y/256/4096*2+X/256/4096,Y/256/2048*4+X/256/2048,Y/256/1024*8+X/256/1024,Y/256/512*16+X/256/512,Y/256/256*32+X/256/256,Y/256/128*64+X/256/128,Y/256/64*128+X/256/64,Y/256/32*256+X/256/32,Y/256/16*512+X/256/16,Y/256/8*1024+X/256/8,Y/256/4*2048+X/256/4,Y/256/2*4096+X/256/2,Y/256*8192+X/256
-- old ORDER BY: ORDER BY Y/256*8192+X/256

\copy (SELECT X,Y,CASE WHEN Z > 65.535 THEN 65535 ELSE CAST(Z*1000.0 AS INT) END AS Z FROM Temp2 ORDER BY Y/256/4096*2+X/256/4096,Y/256/2048*4+X/256/2048,Y/256/1024*8+X/256/1024,Y/256/512*16+X/256/512,Y/256/256*32+X/256/256,Y/256/128*64+X/256/128,Y/256/64*128+X/256/64,Y/256/32*256+X/256/32,Y/256/16*512+X/256/16,Y/256/8*1024+X/256/8,Y/256/4*2048+X/256/4,Y/256/2*4096+X/256/2,Y/256*8192+X/256) to '/tmp/ios13.csv' csv

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
