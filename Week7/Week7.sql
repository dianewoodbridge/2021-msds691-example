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

ALTER TABLE epa_air_quality_full
ADD PRIMARY KEY (date, site_id, poc);


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

--Info table which is global for all the rows and not dependent to any candidate keys.
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DROP TABLE IF EXISTS epa_info;
CREATE TABLE epa_info AS
(
	SELECT DISTINCT aqs_parameter_code, aqs_parameter_desc, source, units, state_code, state
	FROM epa_air_quality_full
);
ALTER TABLE epa_info ADD PRIMARY KEY (aqs_parameter_code);
COMMIT;

SELECT * FROM epa_info;


--Location-related table
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DROP TABLE IF EXISTS epa_site_location CASCADE;
CREATE TABLE epa_site_location AS
(
	SELECT DISTINCT site_id, site_name, site_latitude, site_longitude, county_code, county, cbsa_code, cbsa_name
	FROM epa_air_quality_full
);
ALTER TABLE epa_site_location ADD PRIMARY KEY (site_id);
ALTER TABLE epa_air_quality_full ADD CONSTRAINT epa_site_foreign_key FOREIGN KEY (site_id) REFERENCES epa_site_location(site_id) ON UPDATE CASCADE ON DELETE CASCADE;
COMMIT;

SELECT * FROM epa_site_location;

--Choose columns on the epa_air_quality that has candiate_keys and qualifying columns that are dependent on the entire candidate key.
ALTER TABLE epa_air_quality_full 
			DROP COLUMN site_name,
			DROP COLUMN site_latitude,
			DROP COLUMN site_longitude,
			DROP COLUMN county_code,
			DROP COLUMN county,
			DROP COLUMN cbsa_code,
			DROP COLUMN cbsa_name,
			DROP COLUMN state_code,
			DROP COLUMN state,
			DROP COLUMN aqs_parameter_code,
			DROP COLUMN aqs_parameter_desc,
			DROP COLUMN source,
			DROP COLUMN units;
			
SELECT * FROM epa_air_quality_full;

-------------------------------------------------------------------------
-- Ex 4. Create a view called epa_air_quality_2nf_joined to return 
-- the output same as the original data using the normalized tables.
-------------------------------------------------------------------------
BEGIN;
DROP VIEW IF EXISTS epa_air_quality_2nf_joined;
CREATE VIEW epa_air_quality_2nf_joined AS
SELECT  date,
		source,
		epa_site_location.site_id,
		poc,
		daily_mean_pm10_conentration,
		units,
		daily_aqi_value,
		epa_site_location.site_name,
		daily_obs_count,
		percent_complete,
		aqs_parameter_code,
		aqs_parameter_desc,
		epa_site_location.cbsa_code,
		epa_site_location.cbsa_name,
		epa_site_location.county_code,
		epa_site_location.county,
		epa_site_location.site_latitude,
		epa_site_location.site_longitude 
FROM epa_air_quality_full
JOIN epa_site_location
ON epa_air_quality_full.site_id = epa_site_location.site_id
CROSS JOIN epa_info;
COMMIT;

SELECT COUNT(*) FROM epa_air_quality_2nf_joined;

-------------------------------------------------------------------------
--Ex 5. Create the insert_epa_data() function to insert a row in a format of (date, source, poc, daily_mean_pm10_conentration, units, daily_aqi_value, site_name, daily_obs_count, percent_complete, aqs_parameter_code, aqs_parameter_desc, cbsa_code, cbsa_name, state_code, state, county_code, county, site_latitude, site_longitude) to the normalized tables (2NF).
-------------------------------------------------------------------------
SELECT MAX(date) FROM epa_air_quality_full; --2020-08-31

DROP FUNCTION IF EXISTS insert_epa_data;

--- Function Definition
CREATE FUNCTION insert_epa_data(date_val DATE,
	source_val	VARCHAR(3),
	site_id_val	INTEGER,
	poc_val	INTEGER, 
	daily_mean_pm10_conentration_val	INTEGER,
	units_val	VARCHAR(10),
	daily_aqi_value_val	 INTEGER,
	site_name_val	VARCHAR(50),
	daily_obs_count_val	INTEGER,
	percent_complete_val	REAL,
	aqs_parameter_code_val	INTEGER, 
	aqs_parameter_desc_val	VARCHAR(50),
	cbsa_code_val	VARCHAR(10),
	cbsa_name_val	VARCHAR(50),
	state_code_val	INTEGER,
	state_val	VARCHAR(30),
	county_code_val	INTEGER,
	county_val	VARCHAR(50),
	site_latitude_val	REAL,
	site_longitude_val REAL)
RETURNS VOID AS
$$

INSERT INTO epa_info VALUES (aqs_parameter_code_val, aqs_parameter_desc_val, source_val, units_val, state_code_val, state_val)
ON CONFLICT DO NOTHING;

INSERT INTO epa_site_location VALUES (site_id_val, site_name_val, site_latitude_val, site_longitude_val, county_code_val, county_val, cbsa_code_val, cbsa_name_val)
ON CONFLICT DO NOTHING;

INSERT INTO epa_air_quality_full VALUES (date_val, site_id_val, poc_val, daily_mean_pm10_conentration_val, daily_aqi_value_val, daily_obs_count_val, percent_complete_val) ON CONFLICT DO NOTHING;

$$
LANGUAGE SQL;
----

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

-- Transaction
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DROP TABLE IF EXISTS site_name, site_location, county, site_county, cbsa, county_cbsa;

CREATE TABLE site_name AS
( 
	SELECT DISTINCT site_id, site_name
	FROM epa_site_location
);
ALTER TABLE site_name ADD PRIMARY KEY (site_id);
ALTER TABLE site_name ADD UNIQUE  (site_name);

CREATE TABLE site_location AS
( 
	SELECT DISTINCT site_name, site_longitude, site_latitude
	FROM epa_site_location
);
ALTER TABLE site_location ADD PRIMARY KEY (site_name);
ALTER TABLE site_location ADD CONSTRAINT site_location_foreign_key FOREIGN KEY (site_name) REFERENCES site_name(site_name) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE TABLE county AS
( 
	SELECT DISTINCT county_code, county
	FROM epa_site_location
);
ALTER TABLE county ADD PRIMARY KEY (county_code);

CREATE TABLE site_county AS
(
	SELECT DISTINCT site_id, county_code
	FROM epa_site_location
);
ALTER TABLE site_county ADD PRIMARY KEY (site_id);
ALTER TABLE site_county ADD CONSTRAINT site_id_foreign_key FOREIGN KEY (site_id) REFERENCES epa_site_location(site_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE site_county ADD CONSTRAINT county_code_foreign_key FOREIGN KEY (county_code) REFERENCES county(county_code) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE TABLE cbsa AS
(
	SELECT DISTINCT cbsa_code, cbsa_name
	FROM epa_site_location
);
ALTER TABLE cbsa ADD PRIMARY KEY (cbsa_code);

CREATE TABLE county_cbsa AS
(
	SELECT DISTINCT county_code, cbsa_code
	FROM epa_site_location
);
ALTER TABLE county_cbsa ADD PRIMARY KEY (county_code);
ALTER TABLE county_cbsa ADD CONSTRAINT county_cbsa_county_code_foreign_key FOREIGN KEY (county_code) REFERENCES county(county_code) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE county_cbsa ADD CONSTRAINT county_cbsa_cbsa_code_foreign_key FOREIGN KEY (cbsa_code) REFERENCES cbsa(cbsa_code) ON UPDATE CASCADE ON DELETE CASCADE;

--To alter tables, we need to drop the view as the view is dependant on original columns.
DROP VIEW epa_air_quality_2nf_joined;

ALTER TABLE epa_site_location
DROP COLUMN site_latitude, 
DROP COLUMN site_longitude, 
DROP COLUMN county_code, 
DROP COLUMN county, 
DROP COLUMN cbsa_code, 
DROP COLUMN cbsa_name;

COMMIT;





