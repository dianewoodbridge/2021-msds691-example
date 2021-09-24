DROP TABLE IF EXISTS tweets;

-------------------------------------------------------
-- Ex1. Create a table tweets and insert tweets.csv
-------------------------------------------------------
CREATE TABLE tweets
(
	id NUMERIC,
	time TIMESTAMP,
	hashtag VARCHAR,
	tweet JSON
);

COPY tweets
FROM '/Users/dwoodbridge/Class/2021_MSDS691/2021-msds691-example/Data/tweets.csv'
DELIMITER ','
CSV HEADER;

-- What is the column type of tweet?
SELECT DISTINCT pg_typeof(id), pg_typeof(time), pg_typeof(hashtag), pg_typeof(tweet)
FROM tweets;

-------------------------------------------------------
-- Ex2. In tweets table,
-- return id, time, hashtag, text and retweet_count 
-- when retweet_count is over 100 ordered by retweet_count in descending order.
-------------------------------------------------------
SELECT  id, 
		time,
		hashtag,
		tweet ->> 'text' AS text, 
	   	CAST(tweet -> 'public_metrics' ->> 'retweet_count' AS INTEGER) AS retweet_count
FROM tweets
WHERE CAST(tweet -> 'public_metrics' ->> 'retweet_count' AS INTEGER) > 100
ORDER BY retweet_count DESC;

-------------------------------------------------------
-- Ex3. Use the epa_air_quality table from Week3.
-- Create rows of JSON include all the columns for daily_aqi_value > 200 ordered by daily_aqi_value (ASC)
-------------------------------------------------------
SELECT TO_JSON(epa_air_quality)
FROM epa_air_quality;

SELECT TO_JSON(aqi_over_200)
FROM 
(SELECT * 
 FROM epa_air_quality
 WHERE daily_aqi_value > 200 ORDER BY daily_aqi_value) AS aqi_over_200;

-------------------------------------------------------
-- Ex4. For January of 2020, return site_id, date, daily_mean_pm10_concentration, 
-- and it average between the first day  and the current date per site_id.
-------------------------------------------------------
SELECT site_id, date, daily_mean_pm10_concentration, AVG(daily_mean_pm10_concentration) OVER (PARTITION BY site_id ORDER BY date)
FROM epa_air_quality
WHERE EXTRACT(YEAR FROM date) = 2020  AND  EXTRACT(MONTH FROM date) = 1;


--p.20
SELECT site_id, 
	   date, 
	   daily_mean_pm10_concentration, 
	   AVG(daily_mean_pm10_concentration) OVER(), 
	   AVG(daily_mean_pm10_concentration) OVER (PARTITION BY site_id), 
	   AVG(daily_mean_pm10_concentration) OVER (PARTITION BY site_id ORDER BY date),
	   AVG(daily_mean_pm10_concentration) OVER (PARTITION BY site_id ORDER BY date ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING),
	   AVG(daily_mean_pm10_concentration) OVER (PARTITION BY site_id ORDER BY date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),
	   AVG(daily_mean_pm10_concentration) OVER (PARTITION BY site_id ORDER BY date ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
FROM epa_air_quality
WHERE EXTRACT(YEAR FROM date) = 2020  AND  EXTRACT(MONTH FROM date) = 1
ORDER BY site_id, date;

-------------------------------------------------------
-- Ex5.  Calculate the pm10 changes from a day before for each site.
-------------------------------------------------------
SELECT 	site_id, 
		date, 
		daily_mean_pm10_concentration,
		(daily_mean_pm10_concentration -
		LAG(daily_mean_pm10_concentration) OVER (PARTITION BY site_id ORDER BY date)) AS pm10_increase
FROM epa_air_quality;

-- p.24
CREATE OR REPLACE FUNCTION increment(input int) 
RETURNS int AS 
$$ SELECT input + 1 $$ 
LANGUAGE SQL;

SELECT * FROM increment(42);

DROP FUNCTION IF EXISTS increment;

-------------------------------------------------------
-- Ex6. Create a function called site_id_for_name which takes site_name and returns its corresponding site_id.
-- Using this function return all the rows for 'Westmorland' ordered by date.
-------------------------------------------------------
CREATE OR REPLACE FUNCTION  site_id_for_name(name VARCHAR) 
RETURNS TABLE (site_id INTEGER) AS
$$
	SELECT 	site_id
	FROM epa_site_location
	WHERE site_name = name
$$
LANGUAGE SQL;

SELECT * 
FROM epa_air_quality
WHERE site_id =
(SELECT site_id FROM site_id_for_name('Westmorland'))
ORDER BY date;


-------------------------------------------------------
-- Ex7. Create a view called epa_site_info_aqi which returns all the site_id, site_name, site_longitude, site_latitude and corresponding daily_mean_pm10_concentration and daily_aqi_value if exist.
-- Return rows from epa_site_info_aqi where site_name is 'Westmorland'
-------------------------------------------------------
DROP VIEW IF EXISTS epa_site_info_aqi;

CREATE VIEW epa_site_info_aqi AS
SELECT 	epa_site_location.site_id,
		date,
		site_name,
		site_longitude,
		site_latitude,
		daily_mean_pm10_concentration,
		daily_aqi_value
FROM epa_site_location
LEFT JOIN epa_air_quality
ON epa_air_quality.site_id = epa_site_location.site_id;

SELECT *
FROM epa_site_info_aqi
WHERE site_name = 'Westmorland';

-------------------------------------------------------
-- Ex8. Create a view called epa_aqi_2020_01 which only stores January of 2020 data from epa_air_quality.
-- Make sure it only stores/updates data from January, 2020.
-------------------------------------------------------
DROP VIEW IF EXISTS epa_aqi_2020_01;

CREATE VIEW epa_aqi_2020_01 AS
SELECT *
FROM epa_air_quality
WHERE EXTRACT(YEAR FROM date) = 2020 AND EXTRACT(MONTH FROM date) = 1
--WITH CHECK OPTION;

-- Compare with/without "WITH CHECK OPTION"
INSERT INTO epa_aqi_2020_01 VALUES
('2021-09-24', 60070008, 80, 80);


