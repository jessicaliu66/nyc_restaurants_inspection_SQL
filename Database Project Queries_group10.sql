-- Final project part 3

USE final;

# Q1: An overview of restaurants by cuisine type -- 
# Calcualte the number of restaurants, average capacity, average open year for each cuisine,
# and order by descending restaurant count.

SELECT cuisine, COUNT(restaurant_id) AS restaurant_count, ROUND(AVG(capacity),0) AS avg_capacity, 
ROUND(AVG(YEAR(NOW()) - open_year),0) AS avg_open_year
FROM restaurants
GROUP BY cuisine
ORDER BY restaurant_count DESC; 

-- The top 3 cuisines with the most restaurants in our database are:
/*
# 'cuisine', 'restaurant_count', 'avg_capacity', 'avg_open_year'
	'American','6','60','11'
	'Italian','3','63','13'
	'Irish','2','65','8'
*/
-- From above, we find that American is the most common cuisine type with 6 restaurants.
-- The top 3 cuisine types all have similar average capacity around 60.
-- Among the top 3 cuisines, Italian seems to have the oldest restaurants in average, with an average "age" of 13.


# Q2: "The target resaurants" -- 
# The average interval between inspections for each restaurant (that has been inspected), 
# compared with average level for all restaurants

DROP TABLE IF EXISTS inspection_interval;

CREATE TEMPORARY TABLE inspection_interval AS
(
SELECT restaurant_id, name, COUNT(inspection_id) AS inspection_count, ROUND(AVG(DATEDIFF(inspection_date, last_date)), 1) AS avg_inspection_interval, ROUND(avg_level, 1) AS avg_level,
CASE
	WHEN AVG(DATEDIFF(inspection_date, last_date)) > avg_level THEN "Longer than average"
    WHEN AVG(DATEDIFF(inspection_date, last_date)) < avg_level THEN "Shorter than average"
    WHEN AVG(DATEDIFF(inspection_date, last_date)) = avg_level THEN "Same as average"
    ELSE "Less than 2 inspections"
END AS interval_level
FROM (
	SELECT r.restaurant_id, r.name, i.inspection_id, i.inspection_date, i.last_date,
        AVG(DATEDIFF(i.inspection_date, i.last_date)) OVER() AS avg_level
	FROM restaurants AS r
	INNER JOIN (SELECT *, LAG(inspection_date) OVER(PARTITION BY restaurant_id ORDER BY inspection_date) AS last_date
				FROM inspections) AS i
		ON r.restaurant_id = i.restaurant_id
	) AS ri
GROUP BY restaurant_id, ri.avg_level
ORDER BY avg_inspection_interval
);

SELECT *
FROM inspection_interval;

-- From the temporary table, "P & S DELI GROCERY" seems like the inspectors' favorite spot,
-- with an average inspection interval of 182 days, which is much shorter than the average level of 410.5 days.
-- On the contrarary, "KEATS RESTAURANT" waited 1043 days for its next inspection, which is almost 3 years from its last one!


# Q3: Average performance ranking (from worst to best) --
# Calculation the average inspection score for each resataurant, and rank in DESC. 
# (The "score" variable is the deducted score, i.e. penalty.)

WITH avg_score AS 
(SELECT r.restaurant_id, r.name, ROUND(AVG(i.score), 2) AS deducted_score
FROM inspections AS i
     LEFT JOIN restaurants AS r # include only the restaurants with at least 1 inspection record
     ON i.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id)

SELECT restaurant_id, name,
CASE 
  WHEN deducted_score != 0 THEN deducted_score
  ELSE 0
END AS average_deducted_score,
DENSE_RANK() OVER(ORDER BY deducted_score DESC) AS ranked
FROM avg_score;

-- From the result table, we can find that the top 5 restaurants with the worst average performance are:
/*
# 'restaurant_id', 'name', 'average_deducted_score', 'ranked'
	'5','SEVILLA RESTAURANT','19.33','1'
	'11','SHUN LEE PALACE RESTAURANT','18.00','2'
	'14','CAFE RIAZOR','16.67','3'
	'12','MEXICO LINDO RESTAURANT','16.00','4'
	'6','MCSORLEYS OLD ALE HOUSE','15.67','5'
*/
-- 'SEVILLA RESTAURANT' has the highest penalty score per inspection, and should pay more attention to their compliance.


# Q4: Most common problems --
# Find the most common critical/non-critical violation type in each year and their count

WITH violation_rank AS 
(
SELECT *, DENSE_RANK() OVER(PARTITION BY year, critical_flag ORDER BY violation_count DESC) AS v_rank
FROM
(
	SELECT YEAR(i.inspection_date) AS year, vt.violation_code, vt.violation_description, vt.critical_flag, 
		COUNT(v.violation_id) AS violation_count
	FROM inspections AS i
	INNER JOIN violations AS v
		ON i.inspection_id = v.inspection_id
	INNER JOIN violation_types AS vt
		ON v.violation_code = vt.violation_code
	GROUP BY year, vt.critical_flag, vt.violation_code
) AS v_count
)

SELECT year, critical_flag AS critical, violation_description AS most_common_violation, violation_count AS count
FROM violation_rank
WHERE v_rank = 1
ORDER BY year DESC, critical_flag DESC;

-- Mice Problem: From 2021 to 2023, the most common critical violation type has always been 
-- "Evidence of mice or live mice in establishment's food or non-food areas."

-- As for non-critical violations, the most common types vary more between years.
-- Violation with "Non-food contact surface" seems to be the most common non-critical violation type, ranking the top in 2023, 2022 and 2019.
