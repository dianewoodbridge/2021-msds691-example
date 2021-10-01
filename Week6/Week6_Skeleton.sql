-----------------------------
-- Drop, create and load data
------------------------------
DROP TABLE IF EXISTS epa_air_quality;
DROP TABLE IF EXISTS epa_site_location;

CREATE TABLE epa_site_location
(
	site_id INTEGER CHECK (site_id > 0),
	site_name VARCHAR NOT NULL,
	site_latitude REAL NOT NULL,
	site_longitude REAL NOT NULL,
	county VARCHAR NOT NULL,
	state VARCHAR NOT NULL,
	PRIMARY KEY (site_id)
);

CREATE TABLE epa_air_quality
(
	date DATE DEFAULT CURRENT_DATE,
	site_id INTEGER CHECK (site_id > 0),
	daily_mean_pm10_concentration REAL NOT NULL,
	daily_aqi_value REAL NOT NULL,
	PRIMARY KEY (date, site_id),
	FOREIGN KEY (site_id) REFERENCES epa_site_location (site_id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO epa_site_location VALUES (60070008,	'Chico-East Avenue', 39.76168, -121.84047, 'Butte', 'California');


COPY epa_site_location
FROM '/Users/dwoodbridge/Class/2021_MSDS691/Example/Data/epa_site_location.csv'
DELIMITER ','
CSV HEADER;

COPY epa_air_quality
FROM '/Users/dwoodbridge/Class/2021_MSDS691/Example/Data/epa_air_quality.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO epa_site_location VALUES (60070001,	'Central Marin', 38.0834, -122.7633, 'Marin', 'California');


SELECT * FROM epa_air_quality;

--EX 1-3. Atomicity
--Ex 1. Abort
--Write a transaction for epa_site_location that
--A.Return the number of records for site_id = 60270004.
--B.Wait for 10 seconds 
----SELECT pg_sleep(seconds)
--C.Delete rows where site_id = 60270004.
--D.Return the number of records for site_id = 60270004.
--E.What happens if you rollback?
--F.Return the number of records for site_id = 60270004.
--Are outputs of A, D and F are the same?




--Ex 2. Abort
--Write a transaction for epa_site_location that
--A.Return the number of records for site_id = 60270004.
--B.Wait for 10 seconds 
----SELECT pg_sleep(seconds)
--C.Updated site_id to  60270005 where site_id = 60270004.
--D.Return the number of records for site_id = 60270004.
--E.What happens if you coommit?
--F.Return the number of records for site_id = 60270004.
--Are outputs of A, D and F are the same?




--Ex 3. Commit
--Write a transaction for epa_site_location that
--A.Return the number of records for site_id = 60270004.
--B.Wait for 10 seconds 
----SELECT pg_sleep(seconds)
--C.Delete rows where site_id = 60270004.
--D.Return the number of records for site_id = 60270004.
--E.What happens if you rollback?
--F.Return the number of records for site_id = 60270004.
--Are outputs of A, D and F are the same?


--Ex 4. 
----Query tool 1 (start first)
--Write a transaction for epa_air_quality that
-- A. Return the number of records for site_id = 60070008.
-- B. Wait for 10 seconds 
----  SELECT pg_sleep(seconds)
-- C. Delete rows where site_id = 60070008.
-- D. Return the number of records for site_id = 60070008.
-- E. What happens if you commit?
-- F. Return the number of records for site_id = 60070008.
BEGIN;
SELECT COUNT(*) FROM epa_air_quality WHERE site_id = 60070008; -- 170 
SELECT pg_sleep(10);
DELETE FROM epa_air_quality WHERE site_id = 60070008; 
SELECT COUNT(*) FROM epa_air_quality WHERE site_id = 60070008; -- 0
COMMIT;
SELECT COUNT(*) FROM epa_air_quality WHERE site_id = 60070008; -- 0

---- Query tool 2 (start right after the first one)
-- Write a transaction for epa_air_quality that
-- Return the number of records for site_id = 60070008.
-- A. Wait for 10 seconds 
---- SELECT pg_sleep(seconds)
-- B. INSERT INTO epa_air_quality VALUES (“2020-01-17",	60070008, 7, 6);
-- C. Return the number of records for site_id = 60070008.
-- D. What happens if you commit?
-- E. Return the number of records for site_id = 60070008.
BEGIN;
SELECT COUNT(*) FROM epa_air_quality WHERE site_id = 60070008; -- 170
SELECT pg_sleep(10);
INSERT INTO epa_air_quality VALUES (“2020-01-17",	60070008, 7, 6);
SELECT COUNT(*) FROM epa_air_quality WHERE site_id = 60070008; -- 171
COMMIT;
SELECT COUNT(*) FROM epa_air_quality WHERE site_id = 60070008; -- 1

