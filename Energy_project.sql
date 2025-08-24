
-- Energy Project


-- Struggled to import data as got 'Unhandled exception: 'ascii' codec can't decode byte 0xef in position 0: ordinal not in range(128) Check the log for more details.' error so I saved file as UTG-8 which worked for renewable data but it still didn't work for CO2 data so i changed it to ASCII.

SELECT *
FROM `renewable-share-energy`; 
-- For some reason this didn't work (add backticks when you have hyphens in name). Still didn't work


USE energy_project;
SHOW TABLES;

SELECT * FROM `renewable-share-energy`;
-- I realised I was in the wrong schemas, it works now


SELECT * FROM `co-emissions-per-capita`;



SELECT 
    r.Entity AS country,
    r.Year,
    r.`Renewables (% equivalent primary energy)` AS renewable_share,
    c.`Annual CO? emissions (per capita)` AS co2_per_capita
FROM 
    `renewable-share-energy` AS r
JOIN 
    `co-emissions-per-capita` AS c
ON 
    r.Entity = c.Entity
    AND r.Year = c.Year
ORDER BY 
    r.Entity, r.Year;
-- I think this only temporarily changes the names just for this query so I'll have to alter table



ALTER TABLE `renewable-share-energy`
CHANGE COLUMN `Renewables (% equivalent primary energy)` renewable_share DOUBLE;

ALTER TABLE `co-emissions-per-capita`
CHANGE COLUMN `Annual CO? emissions (per capita)` co2_per_capita DOUBLE;
-- SQL didn't read CO2 column correctly but it's fine as I renamed it


SELECT * FROM `co-emissions-per-capita`;
-- double-checking to see if column name changed- yep :D



SELECT 
    r.Entity,
    r.Year,
    r.renewable_share,
    c.co2_per_capita
FROM 
    `renewable-share-energy` AS r
JOIN 
    `co-emissions-per-capita` AS c
ON 
    r.Entity = c.Entity
    AND r.Year = c.Year
ORDER BY 
    r.Entity, r.Year;
    
    
SELECT DISTINCT Entity
FROM `renewable-share-energy`
ORDER BY Entity;
-- Other than country names, we have entities like Africa (EI), Non-OECD, world, European union (27), Eastern Africa (EI), high-income countries, etc...


SELECT DISTINCT r.Entity
FROM `renewable-share-energy` AS r
JOIN `co-emissions-per-capita` AS c
ON r.Entity = c.Entity AND r.Year = c.Year
ORDER BY r.Entity;
-- With the join, some of these entities disappear
-- The names look consistent with no repeats like USA and United States :)
-- However, there are still entities like High-income countries, world, European Union (27) but this can be useful for analysis so for now I'll keep them just in case.



WITH joined AS (
    SELECT r.Entity, r.Year
    FROM `renewable-share-energy` r
    JOIN `co-emissions-per-capita` c
    ON r.Entity = c.Entity AND r.Year = c.Year
)
SELECT Entity, Year, COUNT(*) AS duplicates
FROM joined
GROUP BY Entity, Year
HAVING COUNT(*) > 1;
-- COUNT(*) counts all rows 
-- This is a CTE and we're checking to see if any data has duplicates
-- There's none :D



WITH joined AS (
    SELECT r.Entity, r.Year, r.renewable_share,
           c.co2_per_capita
    FROM `renewable-share-energy` r
    JOIN `co-emissions-per-capita` c
    ON r.Entity = c.Entity AND r.Year = c.Year
)
SELECT *
FROM joined
WHERE Entity IS NULL OR Entity = ' '
   OR Year IS NULL OR Year = ' '
   OR renewable_share IS NULL OR renewable_share = ' '
   OR co2_per_capita IS NULL OR co2_per_capita = ' ';
   -- There are no null values
   
   
SELECT r.Year, 
       AVG(c.co2_per_capita) AS avg_co2, 
       AVG(r.renewable_share) AS avg_renewables
FROM `renewable-share-energy` r
JOIN `co-emissions-per-capita` c
ON r.Entity = c.Entity AND r.Year = c.Year
GROUP BY r.Year
ORDER BY r.Year;
-- Average renewable energy share has increased over time
-- Average CO2 emissions increase, then from the 70s to early 2000s fluctuate and after that start to decrease slowly



WITH Country_Year AS (
    SELECT r.Entity AS Country, r.Year, c.co2_per_capita
    FROM `renewable-share-energy` r
    JOIN `co-emissions-per-capita` c
    ON r.Entity = c.Entity AND r.Year = c.Year
)
SELECT *, DENSE_RANK() OVER (PARTITION BY Year ORDER BY co2_per_capita DESC) AS co2_rank
FROM Country_Year
WHERE Year = 2020
ORDER BY co2_rank;
-- In 2020, Qatar had the highest co2 per capita which was 36.6 t 



WITH Country_Year AS (
    SELECT r.Entity AS Country, r.Year, r.renewable_share
    FROM `renewable-share-energy` r
    JOIN `co-emissions-per-capita` c
    ON r.Entity = c.Entity AND r.Year = c.Year
)
SELECT *, DENSE_RANK() OVER (PARTITION BY Year ORDER BY renewable_share DESC) AS renewable_rank
FROM Country_Year
WHERE Year = 2020
ORDER BY renewable_rank;
-- In 2020 Iceland had the highest renewable energy share of 86.1% of primary energy


WITH Country_Year AS (
    SELECT r.Entity AS Country, r.Year, r.renewable_share
    FROM `renewable-share-energy` r
    JOIN `co-emissions-per-capita` c
    ON r.Entity = c.Entity AND r.Year = c.Year
)
SELECT *, DENSE_RANK() OVER (PARTITION BY Year ORDER BY renewable_share ASC) AS renewable_rank
FROM Country_Year
WHERE Year = 2020
ORDER BY renewable_rank;
-- In 2020 Turkmenistan had the lowest renewable share of 0.0056
-- Qatar had the 5th lowest renewable share of 0.078 in 2020



SELECT r.Entity AS Country, AVG(c.co2_per_capita) AS avg_emissions
FROM `renewable-share-energy` r
JOIN `co-emissions-per-capita` c
ON r.Entity = c.Entity AND r.Year = c.Year
GROUP BY r.Entity
ORDER BY avg_emissions DESC;
-- Each countries' average emissions 
-- Qatar highest


SELECT r.Entity AS Country, AVG(r.renewable_share) AS avg_renewables
FROM `renewable-share-energy` r
JOIN `co-emissions-per-capita` c
ON r.Entity = c.Entity AND r.Year = c.Year
GROUP BY r.Entity
ORDER BY avg_renewables DESC;
-- Each countries' average renewable share energy 
-- Norway highest followed by Iceland :0


SELECT r.Year, AVG(r.renewable_share) AS avg_renewables, AVG(c.co2_per_capita) AS avg_co2
FROM `renewable-share-energy` r
JOIN `co-emissions-per-capita` c
ON r.Entity = c.Entity AND r.Year = c.Year
GROUP BY r.Year
ORDER BY r.Year;
-- Global averages over time


SELECT 
    r.Entity AS Country, 
    r.Year, 
    r.renewable_share, 
    c.co2_per_capita
FROM `renewable-share-energy` r
JOIN `co-emissions-per-capita` c
ON r.Entity = c.Entity AND r.Year = c.Year;
-- I'll export this query to use for Tableau
-- Go to query- export results- save as csv- then open it in tableau




