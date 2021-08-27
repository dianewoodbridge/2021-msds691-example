DROP TABLE IF EXISTS epa_air_quality;
DROP TABLE IF EXISTS epa_site_location;

------------------------------------------------------------
--Ex 4. Create msds691 database.
------------------------------------------------------------
CREATE DATABASE msds691;

------------------------------------------------------------
--Ex 5. Create epa_air_quality and epa_site_location tables.
--      Add Integrity Constraints
------------------------------------------------------------
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
	daily_mean_pm10_conentration REAL NOT NULL,	
	daily_aqi_value REAL NOT NULL,
	PRIMARY KEY (date, site_id),
	FOREIGN KEY (site_id) REFERENCES epa_site_location (site_id) ON UPDATE CASCADE ON DELETE CASCADE
);


------------------------------------------------------------
--Ex 6. Insert data into epa_air_quality  and epa_site_location
-- epa_air_quality
--  date : 2021-08-27	
--  site_id : 60070008	
--  daily_mean_pm10_conentration : 27
--  daily_aqi_value : 25


-- epa_site_location
--  site_id  : 60070008	
--  sit e_name : Chico-East Avenue	
--  site_latitude : 39.76168	
--  site_longitude : -121.84047	
--  county : Butte	
--  state : California	
------------------------------------------------------------
INSERT INTO epa_air_quality VALUES ('2021-08-27', 60070008, 27, 25);
INSERT INTO epa_site_location VALUES (60070008,	'Chico-East Avenue', 39.76168, -121.84047, 'Butte', 'California');

------------------------------------------------------------
-- Ex 7. Load data from  epa_air_quality.csv  and epa_site_location.csv 
-- to the  epa_air_quality  and epa_site_location table.
------------------------------------------------------------
COPY epa_site_location 
FROM '/Users/dwoodbridge/Class/2021_MSDS691/Example/Data/epa_site_location.csv'
DELIMITER ','
CSV HEADER;

COPY epa_air_quality 
FROM '/Users/dwoodbridge/Class/2021_MSDS691/Example/Data/epa_air_quality.csv'
DELIMITER ','
CSV HEADER;

------------------------------------------------------------
--Ex 8. Update site_id from  60070008 to  60070001 in epa_air_quality. 
--		Update site_id from 60270029 to 60000029 in epa_site_location table.
-- 	What happens?
------------------------------------------------------------
INSERT INTO epa_site_location VALUES (60070001,	'Central Marin', 38.0834, -122.7633, 'Marin', 'California');

SELECT * FROM epa_air_quality WHERE site_id = 60070001;
SELECT * FROM epa_site_location WHERE site_id = 60070001;

UPDATE epa_air_quality SET site_id = 60070001 WHERE site_id = 60070008;

SELECT * FROM epa_air_quality WHERE site_id = 60070008;
SELECT * FROM epa_site_location WHERE site_id = 60070008;
---
SELECT * FROM epa_air_quality WHERE site_id = 60270029;
SELECT * FROM epa_site_location WHERE site_id = 60270029;

UPDATE epa_site_location SET site_id = 60000029 WHERE site_id = 60270029;

SELECT * FROM epa_air_quality WHERE site_id = 60000029;
SELECT * FROM epa_site_location WHERE site_id = 60000029;

------------------------------------------------------------
--Ex 9. Delete the row where date is ‘2020-01-01’ in epa_air_quality table.

--  Delete the epa_site_location table.
--  What happens?
------------------------------------------------------------
DELETE FROM epa_air_quality WHERE date = '2020-01-01';

DROP TABLE epa_site_location;

--Compare between 1) and 2)
--1)
ALTER TABLE epa_air_quality DROP CONSTRAINT epa_air_quality_site_id_fkey;
DROP TABLE epa_site_location;
SELECT * FROM epa_air_quality;

--2)
DROP TABLE epa_site_location CASCADE;
SELECT * FROM epa_air_quality;
