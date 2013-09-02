SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRANSACTION;
CREATE TEMPORARY TABLE IF NOT EXISTS Temp1(X1 INT, Y1 INT, captured_at INT2, DRE FLOAT4);
TRUNCATE TABLE Temp1;

-- first insert is for NON Japan Post (ie, normal) data
INSERT INTO Temp1(X1, Y1, captured_at, DRE)
SELECT CAST((CAST(ST_X(location::geometry) AS FLOAT)+180.0)/360.0*2097152.0+0.5 AS INT) AS X1
    ,CAST((0.5-LN((1.0+SIN(CAST(ST_Y(location::geometry) AS FLOAT)*pi()/180.0))/(1.0-SIN(CAST(ST_Y(location::geometry) AS FLOAT)*pi()/180.0)))/(4.0*pi()))*2097152.0+0.5 AS INT) AS Y1
    ,CAST(EXTRACT(epoch FROM captured_at)/86400 AS INT2) AS captured_at
    ,CASE
        WHEN unit='cpm' AND device_id IS NULL THEN value/350.0
        WHEN unit='microsievert' THEN value
        WHEN unit='cpm' AND device_id IN (5,15,16,17,18,22) THEN value/350.0
        WHEN unit='cpm' AND device_id IN (6,7,11,13,23) THEN value/100.0
        WHEN unit='cpm' AND device_id IN (4,9,10,12,19,24) THEN value/132.0
        WHEN unit='cpm' AND device_id IN (21) THEN value/1750.0
        ELSE 0.0
    END AS DRE
FROM measurements
WHERE user_id != 347
    AND captured_at IS NOT NULL
    AND captured_at > TIMESTAMP '2011-03-01 00:00:00'
    AND captured_at < localtimestamp + interval '48 hours'
    AND ST_X(location::geometry) IS NOT NULL
    AND ST_Y(location::geometry) IS NOT NULL
    AND value IS NOT NULL
    AND (device_id IS NULL OR device_id <= 24 OR unit='microsievert')
    AND (  CAST(ST_X(location::geometry) AS FLOAT) != 0.0
        OR CAST(ST_Y(location::geometry) AS FLOAT) != 0.0)
    AND (  (unit='cpm' AND value > 10.0 AND value < 30000.0)
        OR (unit='microsievert' AND value > 0.02 AND value < 75.0))
    AND id NOT IN (13194822,15768545,15768817,15690104,15768346,15768782,15768792,16381794,18001818,17342620,14669786,25389168,25389158,25389157,25389153,24482487,16537265,16537266,19554057,19554058,19554059,19554060,19555677,19589301,19589302,19589303,19589304,19589305,19589303,19589304,19589305,19600634,19699406)
    AND (id < 23181608 OR id > 23182462)
    AND CAST(ST_Y(location::geometry) AS FLOAT) < 85.05
    AND CAST(ST_Y(location::geometry) AS FLOAT) > -85.05
    AND CAST(ST_X(location::geometry) AS FLOAT) >= -180.0
    AND CAST(ST_X(location::geometry) AS FLOAT) <=  180.0;
    
-- This 2nd insert is a hack workaround for JP post data
-- -10k to the "days since 1970" is approx a -30 year penalty to the date restrictive binning so as not to
--       contaminate measurements with superior spatial resolution
-- Although that's a little unfair to 1970, because LANDSAT 5 had better resolution than the Japan Post.
INSERT INTO Temp1(X1, Y1, captured_at, DRE)
SELECT CAST((CAST(ST_X(location::geometry) AS FLOAT)+180.0)/360.0*2097152.0+0.5 AS INT)+2 AS X1
    ,CAST((0.5-LN((1.0+SIN(CAST(ST_Y(location::geometry) AS FLOAT)*pi()/180.0))/(1.0-SIN(CAST(ST_Y(location::geometry) AS FLOAT)*pi()/180.0)))/(4.0*pi()))*2097152.0+0.5 AS INT)-2 AS Y1
    ,CAST(EXTRACT(epoch FROM captured_at)/86400 AS INT2)-10950 AS captured_at
    ,CASE
        WHEN unit='cpm' AND device_id IS NULL THEN value/350.0
        WHEN unit='microsievert' THEN value
        WHEN unit='cpm' AND device_id IN (5,15,16,17,18,22) THEN value/350.0
        WHEN unit='cpm' AND device_id IN (6,7,11,13,23) THEN value/100.0
        WHEN unit='cpm' AND device_id IN (4,9,10,12,19,24) THEN value/132.0
        WHEN unit='cpm' AND device_id IN (21) THEN value/1750.0
        ELSE 0.0
    END AS DRE
FROM measurements
WHERE user_id = 347
    AND captured_at IS NOT NULL
    AND captured_at > TIMESTAMP '2011-03-01 00:00:00'
    AND captured_at < localtimestamp + interval '48 hours'
    AND ST_X(location::geometry) IS NOT NULL
    AND ST_Y(location::geometry) IS NOT NULL
    AND value IS NOT NULL
    AND (device_id IS NULL OR device_id <= 24 OR unit='microsievert')
    AND (  CAST(ST_X(location::geometry) AS FLOAT) != 0.0
        OR CAST(ST_Y(location::geometry) AS FLOAT) != 0.0)
    AND (  (unit='cpm' AND value > 17.0 AND value < 30000.0)
        OR (unit='microsievert' AND value > 0.02 AND value < 75.0))
    AND CAST(ST_Y(location::geometry) AS FLOAT) < 85.05
    AND CAST(ST_Y(location::geometry) AS FLOAT) > -85.05
    AND CAST(ST_X(location::geometry) AS FLOAT) >= -180.0
    AND CAST(ST_X(location::geometry) AS FLOAT) <=  180.0;
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

\copy (SELECT X,Y,CASE WHEN Z > 65.535 THEN 65535 ELSE CAST(Z*1000.0 AS INT) END AS Z FROM Temp2 ORDER BY Y/256*8192+X/256) to '/mnt/tmp/ios13.csv' csv

DROP TABLE Temp2;
