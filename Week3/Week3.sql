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
SELECT site_id,
	   site_name, 
	   county,
	   CASE WHEN site_latitude < 37 THEN 'Southern California' ELSE 'Norther California' END AS state,
	   site_latitude, 
	   site_longitude
FROM epa_site_location;

------------------------------------------------------------
-- Ex 2.
-- 2A. Return rows  from epa_site_location where it is in 'Butte', 
-- 'Lassen', 'Yuba' or 'Kern' county ordered by site_id.
------------------------------------------------------------
SELECT *
FROM epa_site_location
WHERE county IN ('Butte', 'Lassen', 'Yuba', 'Kern')
ORDER BY site_id;

------------------------------------------------------------
-- 2B. Return rows where its daily_mean_pm10_concentration is higher than 
-- any values between '2020-08-01' and '2020-11-15' ordered by date.
------------------------------------------------------------

SELECT * 
FROM epa_air_quality
WHERE daily_mean_pm10_concentration >= ALL(SELECT daily_mean_pm10_concentration
										   FROM epa_air_quality 
										   WHERE date >= '2020-08-01' AND date <= '2020-11-15')
ORDER BY date; 
										   
										   
SELECT * 
FROM epa_air_quality
WHERE daily_mean_pm10_concentration >= (SELECT MAX(daily_mean_pm10_concentration)
										FROM epa_air_quality 
										WHERE date >= '2020-08-01' AND date <= '2020-11-15')
ORDER BY date; 


------------------------------------------------------------
-- Ex 3. Return rows in epa_site_location 
-- which site_id does not appear in epa_air_quality ordered by site_id.
------------------------------------------------------------
SELECT *
FROM epa_site_location
WHERE NOT EXISTS(SELECT * FROM epa_air_quality WHERE epa_site_location.site_id = epa_air_quality.site_id)
ORDER BY site_id;

SELECT * 
FROM epa_site_location
WHERE site_id IN
(SELECT DISTINCT site_id
 FROM epa_site_location
 EXCEPT
 SELECT DISTINCT site_id
 FROM epa_air_quality
 ORDER BY site_id);

------------------------------------------------------------
-- Ex 4. Return site_id, minimum, average and maximum daily_mean_pm10_concentration 
-- per site_id which has more than 30 records ordered by site_id
------------------------------------------------------------
SELECT site_id, 
	   MIN(daily_mean_pm10_concentration), 
	   AVG(daily_mean_pm10_concentration), 
	   MAX(daily_mean_pm10_concentration)
FROM epa_air_quality
GROUP BY site_id
HAVING COUNT(*) > 30
ORDER BY site_id;

------------------------------------------------------------
-- Ex 5. Return date, site_name, daily_mean_pm10_concentration and daily_aqi_value ordered by site_id and date.
------------------------------------------------------------
SELECT date, 
	   site_name,
	   epa_air_quality.daily_mean_pm10_concentration,
	   epa_air_quality.daily_aqi_value
FROM epa_air_quality
JOIN epa_site_location
ON epa_air_quality.site_id = epa_site_location.site_id
ORDER BY epa_air_quality.site_id, date;

------------------------------------------------------------
-- Ex 6. Assuming that data was supposed to be collected from every station on all the dates in epa_air_quality.
--      Return date, site_id and daily_mean_pm10_concentration and daily_aqi_value for all possible date and site_id pairs ordered by date and site_id.
------------------------------------------------------------
SELECT date_site_id.date, 
	   date_site_id.site_id, 
	   epa_air_quality.daily_mean_pm10_concentration, 
	   epa_air_quality.daily_aqi_value
FROM
	(SELECT  DISTINCT date, epa_site_location.site_id
	 FROM epa_air_quality
	 CROSS JOIN epa_site_location) AS date_site_id
LEFT JOIN epa_air_quality
ON date_site_id.date = epa_air_quality.date 
AND date_site_id.site_id = epa_air_quality.site_id
ORDER BY date, site_id;


------------------------------------------------------------
-- Ex 7 . We are interested in how many readings were collected per site quarterly every year.
-- The output should have cohort(year), site_id,  the number of readings between Jan-Mar, Apr-Jun, Jul-Sep and Oct-Dec ordered by cohort and site_id.
------------------------------------------------------------
SELECT	 EXTRACT(YEAR from cohort) AS year,
		 site_id,
		 COUNT(CASE WHEN DATE_TRUNC('month', date) - cohort < CAST('3 months' AS INTERVAL) THEN 1 END) AS Jan_Mar,
		 COUNT(CASE WHEN DATE_TRUNC('month', date) - cohort > CAST('3 months' AS INTERVAL) AND  DATE_TRUNC('month', date) - cohort < CAST('6 months' AS  INTERVAL) THEN 1 END) AS Apr_Jun,
		 COUNT(CASE WHEN DATE_TRUNC('month', date) - cohort > CAST('6 months' AS INTERVAL) AND  DATE_TRUNC('month', date) - cohort < CAST('9 months' AS  INTERVAL) THEN 1 END) AS Jul_Sept,
		 COUNT(CASE WHEN DATE_TRUNC('month', date) - cohort > CAST('9 months' AS INTERVAL) AND  DATE_TRUNC('month', date) - cohort < CAST('12 months' AS  INTERVAL) THEN 1 END) AS Oct_Dec
FROM
	(SELECT DATE_TRUNC('year', date) AS cohort
	 FROM epa_air_quality
	 GROUP BY cohort) AS cohort
JOIN epa_air_quality
ON DATE_TRUNC('year', epa_air_quality.date) = cohort
GROUP BY cohort, site_id
ORDER BY cohort, site_id;

