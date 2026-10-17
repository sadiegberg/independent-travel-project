-- How much of the data is estimated?
SELECT estimated_fare, COUNT(*) AS rides FROM rides
WHERE include_in_analysis='yes' AND fare_usd IS NOT NULL GROUP BY estimated_fare;

-- Where are the estimates concentrated?
SELECT region, mode, COUNT(*) AS rides, SUM(estimated_fare='yes') AS estimated
FROM rides WHERE include_in_analysis='yes' AND fare_usd IS NOT NULL
GROUP BY region, mode ORDER BY estimated DESC;

-- Do the estimates change the averages?
SELECT mode, ROUND(AVG(fare_usd),2) AS avg_all,
  ROUND(AVG(CASE WHEN estimated_fare='no' THEN fare_usd END),2) AS avg_confirmed_only,
  COUNT(*) AS rides, SUM(estimated_fare='no') AS confirmed
FROM rides WHERE include_in_analysis='yes' AND fare_usd IS NOT NULL
GROUP BY mode ORDER BY avg_all DESC;
