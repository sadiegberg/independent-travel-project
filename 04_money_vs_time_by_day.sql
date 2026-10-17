-- Which currency did the road charge me in each day: money or time?
-- Thresholds: >1.5x overall USD/hour = 'paid in money'; <0.5x = 'paid in time'.
WITH days AS (
  SELECT ride_date, COUNT(*) AS rides,
         ROUND(SUM(fare_usd), 2) AS money_usd,
         SUM(duration_min) AS minutes
  FROM rides
  WHERE include_in_analysis = 'yes'
    AND fare_usd IS NOT NULL AND duration_min IS NOT NULL
  GROUP BY ride_date
),
baseline AS (
  SELECT SUM(money_usd) / (SUM(minutes) / 60.0) AS usd_per_hour FROM days
)
SELECT d.ride_date, d.rides, d.money_usd, d.minutes,
  ROUND(d.money_usd / (d.minutes / 60.0), 2) AS usd_per_hour,
  CASE WHEN d.money_usd / (d.minutes / 60.0) > 1.5 * b.usd_per_hour THEN 'paid in money'
       WHEN d.money_usd / (d.minutes / 60.0) < 0.5 * b.usd_per_hour THEN 'paid in time'
       ELSE 'balanced' END AS the_road_charged_me_in
FROM days d, baseline b
ORDER BY usd_per_hour DESC;
