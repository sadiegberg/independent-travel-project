-- Average fare and cost per minute by mode (analysis rides only)
SELECT mode, COUNT(*) AS rides, ROUND(AVG(fare_usd),2) AS avg_fare_usd,
  ROUND(SUM(fare_usd)/SUM(duration_min),3) AS usd_per_min
FROM rides WHERE include_in_analysis='yes' AND fare_usd IS NOT NULL
GROUP BY mode ORDER BY avg_fare_usd DESC;
