-- Builds the combined rides table from the two imported CSV tables.
-- Prerequisite: import Europe_rides.csv as table "europe" and Central_Asia_rides.csv as table "central_asia"
-- (UTF-8, column names in first line).
CREATE TABLE rides (
  ride_id INTEGER PRIMARY KEY AUTOINCREMENT,
  region TEXT, country TEXT, from_city TEXT, to_city TEXT,
  ride_date TEXT, mode TEXT, operator TEXT, booking_id TEXT,
  fare_local REAL, currency TEXT, fare_usd REAL, estimated_fare TEXT,
  duration_min INTEGER, estimated_duration TEXT, payment TEXT,
  payment_detail TEXT, estimated_payment TEXT, notes TEXT,
  include_in_analysis TEXT
);

INSERT INTO rides (region, country, from_city, to_city, ride_date, mode, operator,
  booking_id, fare_local, currency, fare_usd, estimated_fare, duration_min,
  estimated_duration, payment, payment_detail, estimated_payment, notes,
  include_in_analysis)
SELECT r, country, from_city, to_city,
  printf('%04d-%02d-%02d',
    CAST(substr(date, length(date)-3) AS INTEGER),
    CAST(substr(date, 1, instr(date,'/')-1) AS INTEGER),
    CAST(substr(substr(date, instr(date,'/')+1), 1,
      instr(substr(date, instr(date,'/')+1),'/')-1) AS INTEGER)),
  mode, operator, NULLIF(booking_id,''), NULLIF(fare_local,''), NULLIF(currency,''),
  NULLIF(fare_usd,''), NULLIF(estimated_fare,''), NULLIF(duration_min,''),
  NULLIF(estimated_duration,''), payment, payment_detail, estimated_payment,
  NULLIF(notes,''), include_in_analysis
FROM (SELECT 'Europe' AS r, * FROM europe
      UNION ALL
      SELECT 'Central Asia', * FROM central_asia);
