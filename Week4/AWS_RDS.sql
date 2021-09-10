--https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Procedural.Importing.html#USER_PostgreSQL.S3Import
CREATE EXTENSION aws_s3 CASCADE;

DROP TABLE IF EXISTS epa_air_quality;

CREATE TABLE epa_air_quality
(
	date DATE DEFAULT CURRENT_DATE,
	site_id INTEGER CHECK (site_id > 0),
	daily_mean_pm10_concentration REAL NOT NULL,
	daily_aqi_value REAL NOT NULL,
	PRIMARY KEY (date, site_id)
);

--https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Procedural.Importing.html
SELECT aws_commons.create_s3_uri(
   'usfca-msds691',
   'epa_air_quality.csv',
   'us-west-1'
) AS s3_uri 


--https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Procedural.Importing.html#USER_PostgreSQL.S3Import.FileFormats
SELECT aws_s3.table_import_from_s3(
   'epa_air_quality', 'date,site_id,daily_mean_pm10_concentration, daily_aqi_value', '(FORMAT csv, HEADER true)',
   aws_commons.create_s3_uri('usfca-msds691', 'epa_air_quality.csv','us-west-1'),
   aws_commons.create_aws_credentials('AKIAVOINCV3GWLBLUDPC','jD41X0JNup9D7GTd7i7DO7+WFkMfMiZj9sxqH+KU','')

);

SELECT *
FROM epa_air_quality;
