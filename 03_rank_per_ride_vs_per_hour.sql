-- Is a country cheap per ride also cheap per hour of travel?
WITH base AS (
  SELECT country, COUNT(*) AS rides, AVG(fare_usd) AS avg_fare,
         SUM(fare_usd) / (SUM(duration_min) / 60.0) AS usd_per_hour
  FROM rides
  WHERE include_in_analysis = 'yes'
    AND fare_usd IS NOT NULL AND duration_min IS NOT NULL
  GROUP BY country
  HAVING COUNT(*) >= 3
)
SELECT country, rides,
  ROUND(avg_fare, 2) AS avg_fare_per_ride,
  ROUND(usd_per_hour, 2) AS usd_per_hour,
  RANK() OVER (ORDER BY avg_fare) AS rank_cheapest_per_ride,
  RANK() OVER (ORDER BY usd_per_hour) AS rank_cheapest_per_hour
FROM base
ORDER BY usd_per_hour;
