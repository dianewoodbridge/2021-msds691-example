DROP TABLE IF EXISTS epa_air_quality;
DROP TABLE IF EXISTS epa_site_location;

------------------------------------------------------------
--Ex 4. Create msds691 database.
------------------------------------------------------------


------------------------------------------------------------
--Ex 5. Create epa_air_quality and epa_site_location tables.
--      Add Integrity Constraints
------------------------------------------------------------


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




------------------------------------------------------------
--Ex 7. Load data from  epa_air_quality.csv  and epa_site_location.csv 
-- to the  epa_air_quality  and epa_site_location table.
------------------------------------------------------------



------------------------------------------------------------
--Ex 8. Update site_id from  60070008 to  60070001 in epa_air_quality. 
--		Update site_id from 60270029 to 60000029 in epa_site_location table.
-- 	What happens?
------------------------------------------------------------
INSERT INTO epa_site_location VALUES (60070001,	'Central Marin', 38.0834, -122.7633, 'Marin', 'California');




------------------------------------------------------------
--Ex 9. Delete the row where date is ‘2020-01-01’ in epa_air_quality table.

--  Delete the epa_site_location table.
--  What happens?
------------------------------------------------------------

