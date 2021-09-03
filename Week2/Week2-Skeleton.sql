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


-----------------
-- Ex. 1
--------------------------------------------------------
-- 1.A From epa_air_quality, return all the records where site_id is 60070008.
--------------------------------------------------------


--------------------------------------------------------
-- 1.B From epa_air_quality, return date and daily_aqi_value where site_id is 60070008.
--------------------------------------------------------


--------------------------------------------------------
-- 1.C From epa_air_quality, return unique dates where site_id is 60070008.
--------------------------------------------------------


--------------------------------------------------------
-- 1.D From epa_air_quality, return unique dates where site_id is 60070008 ordered by date (ascending).
--------------------------------------------------------


--------------------------------------------------------
--  1.E From epa_air_quality, return first 5 dates where site_id is 60070008 between 2020-05-01 and 2020-10-01 ordered by date.
--------------------------------------------------------


--------------------------------------------------------
-- 1.F From epa_air_quality, return last 5 dates where site_id is 60070008 between 2020-05-01 and 2020-10-01 ordered by date.
--------------------------------------------------------


------------------------------------------------------------
-- Type Conversion (p.19)
------------------------------------------------------------
SELECT TO_CHAR(TIMESTAMP '2021-04-20 17:31:12.66', 'HH12:MI:SS');
SELECT TO_DATE('05 Dec 2000', 'DD Mon YYYY');
SELECT TO_TIMESTAMP('05 Dec 2000', 'DD Mon YYYY');
SELECT TO_CHAR(-125.8, '999D999S');
SELECT TO_NUMBER('12,454.8-', '99G999D9S');

--------------------------------------------------------
-- Ex 2. 
--------------------------------------------------------
-- 2.A Find the unique integer values of site_latitude and site_longitude in epa_site_location ordered by  latitude in ascending order, and then site longitude in descending order.
