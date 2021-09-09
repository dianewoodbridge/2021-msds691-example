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


------------------------------------------------------------
-- Ex 1. Return site_id, site_name, county, state (either Southern California or Northern California), site_latitude and site_longitude.
--     If site_latitude is smaller than 37, it is “Southern California”. 
------------------------------------------------------------


------------------------------------------------------------
-- Ex 2.
-- 2A. Return rows  from epa_site_location where it is in 'Butte', 
-- 'Lassen', 'Yuba' or 'Kern' county ordered by site_id.
------------------------------------------------------------


------------------------------------------------------------
-- 2B. Return rows where its daily_mean_pm10_concentration is higher than 
-- any values between '2020-08-01' and '2020-11-15' ordered by date.
------------------------------------------------------------



------------------------------------------------------------
-- Ex 3. Return rows in epa_site_location 
-- which site_id does not appear in epa_air_quality ordered by site_id.
------------------------------------------------------------



------------------------------------------------------------
-- Ex 4. Return site_id, minimum, average and maximum daily_mean_pm10_concentration 
-- per site_id which has more than 30 records ordered by site_id
------------------------------------------------------------



------------------------------------------------------------
-- Ex 5. Return date, site_name, daily_mean_pm10_concentration and daily_aqi_value ordered by site_id and date.
------------------------------------------------------------



------------------------------------------------------------
-- Ex 6. Assuming that data was supposed to be collected from every station on all the dates in epa_air_quality.
--      Return date, site_id and daily_mean_pm10_concentration and daily_aqi_value for all possible date and site_id pairs ordered by date and site_id.
------------------------------------------------------------



------------------------------------------------------------
-- Ex 7 . We are interested in how many readings were collected per site quarterly every year.
-- The output should have cohort(year), site_id,  the number of readings between Jan-Mar, Apr-Jun, Jul-Sep and Oct-Dec ordered by cohort and site_id.
------------------------------------------------------------


