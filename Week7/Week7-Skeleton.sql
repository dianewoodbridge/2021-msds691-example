-------------------------------------------------------------------------
--Ex 1. Create a table and load data from Data/epa_air_quality_full.csv.
-------------------------------------------------------------------------
DROP TABLE IF EXISTS epa_air_quality_full CASCADE;

CREATE TABLE epa_air_quality_full
(
	date	DATE,
	source	VARCHAR(3), -- 1 different values
	site_id	INTEGER,
	poc	INTEGER, -- 8 different values
	daily_mean_pm10_conentration	INTEGER,
	units	VARCHAR(10), -- 1 different values
	daily_aqi_value	 INTEGER,
	site_name	VARCHAR(50),
	daily_obs_count	INTEGER,
	percent_complete	REAL,
	aqs_parameter_code	INTEGER, -- 1 different values
	aqs_parameter_desc	VARCHAR(50), -- 1 different values
	cbsa_code	VARCHAR(10), -- 28 different values
	cbsa_name	VARCHAR(50), -- 28 different values
	state_code	INTEGER, -- 1 different values
	state	VARCHAR(30), -- 1 different values
	county_code	INTEGER,
	county	VARCHAR(50),
	site_latitude	REAL,
	site_longitude REAL
);

COPY epa_air_quality_full FROM '/Users/dwoodbridge/Class/2021_MSDS691/Example/Data/epa_air_quality_full.csv' CSV HEADER;



-------------------------------------------------------------------------
-- Ex 2. Convert epa_air_quality_full to 1NF.
-------------------------------------------------------------------------
SELECT COUNT(*) FROM epa_air_quality_full WHERE site_id IS NULL; --15894

SELECT DISTINCT date, site_id, COUNT(poc)
FROM epa_air_quality_full 
GROUP BY date, site_id
HAVING COUNT(*) > 1;

SELECT DISTINCT date, site_id, poc, COUNT(*)
FROM epa_air_quality_full 
GROUP BY date, site_id, poc
HAVING COUNT(*) > 1;

-- TODO: Alter table.


-------------------------------------------------------------------------
-- Ex 3. Normalize epa_air_quality_full in 2NF.
-------------------------------------------------------------------------
SELECT DISTINCT source, units, aqs_parameter_code, aqs_parameter_desc, state_code, state
FROM epa_air_quality_full;

SELECT site_id, COUNT(*)
FROM 
(
	SELECT DISTINCT site_id, 
					site_name,
					cbsa_code,
					cbsa_name,
					state_code,
					state,
					county_code,
					county,
					site_latitude,	
					site_longitude	
	FROM epa_air_quality_full
) AS site_info
GROUP BY site_id
HAVING COUNT(*) != 1;

-- TODO: Info table which is global for all the rows and not dependent to any candidate keys.


-- TODO: Location-related table


-- TODO: Choose columns on the epa_air_quality_full that has candiate_keys and qualifying columns that are dependent on the entire candidate key.


-------------------------------------------------------------------------
-- Ex 4. Create a view called epa_air_quality_2nf_joined to return 
-- the output same as the original data using the normalized tables.
-------------------------------------------------------------------------


-------------------------------------------------------------------------
--Ex 5. Create the insert_epa_data() function to insert a row in a format of (date, source, poc, daily_mean_pm10_conentration, units, daily_aqi_value, site_name, daily_obs_count, percent_complete, aqs_parameter_code, aqs_parameter_desc, cbsa_code, cbsa_name, state_code, state, county_code, county, site_latitude, site_longitude) to the normalized tables (2NF).
-------------------------------------------------------------------------
SELECT MAX(date) FROM epa_air_quality_full; --2020-08-31

DROP FUNCTION IF EXISTS insert_epa_data;

--- TODO: Function Definition


SELECT * FROM insert_epa_data('2020-11-16', 'AQS', 60070008,3,27,'ug/m3 SC',25,'Chico-East Avenue',1,100,81102,'PM10 Total 0-10um STP','17020','Chico, CA',6,'California',7,'Butte',39.76168, -121.84047);

SELECT MAX(date) FROM epa_air_quality_full; --2020-11-16;

-------------------------------------------------------------------------
-- Ex 6. Normalize epa_site_location_full into 3NF.
-------------------------------------------------------------------------
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'epa_site_location';

SELECT site_id, COUNT(site_name) 
FROM epa_site_location
GROUP BY site_id
HAVING COUNT(site_name) != 1;

SELECT site_name, COUNT(site_latitude)
FROM epa_site_location
GROUP BY site_name
HAVING COUNT(*) != 1;


SELECT site_latitude, COUNT(site_longitude)
FROM epa_site_location
GROUP BY site_latitude
HAVING COUNT(site_longitude) != 1;

-- TODO: Transaction





