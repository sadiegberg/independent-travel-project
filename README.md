# Transit Affordability: What the Road Charged Me in Money and Time

A ride-by-ride dataset of how I got around during a 2026 trip through Central Europe, the Balkans, Greece, Central Asia, and Armenia, plus the SQL and Tableau work I used to ask what that movement actually cost.

**[View the interactive dashboard on Tableau Public](https://public.tableau.com/views/transit-affordability-tableau/Dashboard3?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

![Dashboard overview](charts/05_dashboard_overview.png)

- **Period:** June 17 – September 7, 2026
- **Size:** 139 rides (49 in Europe, 90 in Central Asia); 114 are included in the analysis
- **Tools:** DB Browser for SQLite, SQL, Tableau Public, Excel/Sheets for data entry
- **Unit of observation:** one row per ride leg (one ticket or one vehicle)

The data dictionary is in [`DATA_DICTIONARY.md`](DATA_DICTIONARY.md).

## Questions I asked

1. What does a ride cost, by mode of transport?
2. How much of my data is estimated, and does that change the answers?
3. Is a country that looks cheap per ride also cheap per hour of travel?
4. On which days did the road charge me in money, and on which in time?

## Key findings

### 1. Fares vary enormously by mode

![Average fare per ride by mode](charts/01_avg_fare_by_mode.png)

Trains and buses cost roughly 5 to 12 times more per ride than taxis and metros. Average fare per ride (USD), analysis rides only:

| Mode | Avg fare | Rides |
|---|---|---|
| Train | $24.18 | 7 |
| Bus | $18.12 | 22 |
| Ferry | $14.86 | 3 |
| Marshrutka (shared minibus) | $4.16 | 6 |
| Tram | $3.67 | 3 |
| Taxi | $3.49 | 52 |
| Metro | $2.09 | 16 |
| Hitchhiked | $0.00 | 2 |

### 2. About a quarter of fares are estimates, and some modes are entirely estimated

![Estimated vs confirmed fares by mode](charts/02_estimated_vs_confirmed_dumbbell.png)

87 of the 114 analysis rides (76%) have confirmed fares; 27 (24%) are estimates reconstructed from published rates. The chart compares each mode's average using all fares (orange) against confirmed fares only (blue).

- The estimates are concentrated in a few modes. Every ferry and every marshrutka fare in the Europe data is an estimate, and so is half of the Europe bus data.
- **Bus is the biggest swing:** the average is $18.12 with estimates and $30.61 using confirmed fares only. The estimated bus rides are mostly cheap local Albanian buses, while the confirmed ones skew long-distance.
- Train ($24.18 vs. $29.35) and metro ($2.09 vs. $2.66) move less.
- Ferry, shuttle, and marshrutka have no confirmed fares at all, so they show only an orange dot.

### 3. Cheap per ride is not the same as cheap per hour

![Rank per ride vs rank per hour](charts/03_rank_per_ride_vs_per_hour_slope.png)

Ranking countries with at least three analyzable rides (1 = cheapest):

| Country | Rides | Avg fare per ride | USD per hour | Rank per ride | Rank per hour |
|---|---|---|---|---|---|
| Kyrgyzstan | 15 | $5.57 | $3.14 | 4 | 1 |
| Albania | 13 | $9.02 | $3.57 | 7 | 2 |
| Slovenia | 5 | $18.89 | $6.34 | 9 | 3 |
| Uzbekistan | 32 | $5.27 | $6.77 | 2 | 4 |
| Kazakhstan | 14 | $5.37 | $7.89 | 3 | 5 |
| Croatia | 4 | $18.30 | $8.96 | 8 | 6 |
| Greece | 7 | $8.40 | $10.38 | 5 | 7 |
| Austria | 10 | $9.00 | $10.97 | 6 | 8 |
| Armenia | 11 | $3.38 | $12.75 | 1 | 9 |

Armenia is the cheapest country per ride but the most expensive per hour of travel, because its rides were short. Kyrgyzstan flips the other way: mid-pack per ride, cheapest per hour. A fare alone can make a place look affordable when the price of actually going somewhere is not.

### 4. Some days cost money, others cost time

![Calendar heatmap of money vs time](charts/04_money_vs_time_calendar_heatmap.png)

Across 45 travel days, I averaged about $6.14 per hour on the road. I labeled each day relative to that baseline: "paid in money" if it cost more than $9.21 per hour (1.5× the baseline), "paid in time" if it cost less than $3.07 per hour (0.5×).

| Day type | Days | Total spent | Hours traveled |
|---|---|---|---|
| Paid in money | 13 | $275.87 | 20.5 |
| Paid in time | 6 | $53.28 | 22.6 |
| Balanced | 26 | $567.09 | 102.8 |

I spent about the same number of hours on money days and time days, but the money days cost roughly five times as much. In the calendar, money days tend to be city days with short, pricier rides (for example June 19–21 in Vienna and July 18–19 in Athens), while time days are long, cheap rides (for example July 11–12 on Albanian local buses and vans). Blank weeks are gaps between trips with no rides logged.

## How the data was collected

- I logged every ride as I took it (notes, photos, receipts, app history, and bank/card records where I had them).
- Where a fare or duration was missing, I reconstructed it from published fares, operator schedules, and route guides, and flagged it (`estimated_fare`, `estimated_duration`). I did not guess silently.
- Each row's `notes` column records unusual circumstances: bundled prices, rates used, fees, and uncertainty.

## Methodology and rules

- **One row per leg.** A leg is one ticket on one vehicle. A stop where the same vehicle continues (for example, a bus that pauses in another city) is not a separate row. Legs that were purchased together share a `booking_id`.
- **`booking_id` format:** operator code plus the day and month of the booking's first leg, for example `SKY-1706` for a flight booking whose first leg was June 17. Standalone rides leave it blank.
- **Currency.** `fare_local` is in the currency I actually paid. `fare_usd` converts it at the exchange rate on the ride date. Weekend rides use the last weekday rate. A few prepaid tickets use the purchase-date rate; the `notes` column says so. Albanian local fares paid in lek were estimated from published prices and euro equivalents (roughly 94 lek per euro).
- **Bundles.**
  - *Transport-only bundles* (one price covering several rides, no lodging or meals) are split into estimated per-leg fares, and stay in the analysis.
  - *Packages that included lodging, meals, or activities* cannot be split. Their legs have no fare and are excluded from the analysis.
- **Free and included rides.** Hitchhiking is recorded with a fare of 0 and payment `none`, and stays in the analysis. Rides included in lodging or given by someone else have a blank fare and are excluded, because there is no price to compare.
- **`include_in_analysis = no`** applies to flights, package tours, rides included in lodging, and rides provided by others.
- **Durations** are in-vehicle time. They do not include waiting, check-in, or transfers unless noted.
- **Place names** use the local spelling with accents (Shkodër, Tiranë, Sarandë, Gjirokastër). City columns are city-level; parks and villages are named only where there is no city.

## Limitations

- **Estimates.** 24% of analysis fares are estimated, and estimated durations are more common still. Chart 2 shows where this matters most.
- **Small samples.** Slovenia (5 rides) and Croatia (4) are thin; I treat their rankings as suggestive.
- **Mix of rides.** Averages blend short city rides with long intercity trips, which is exactly why fare per ride and fare per hour tell different stories.
- **Arbitrary cutoffs.** The money and time thresholds in the calendar (1.5× and 0.5× the overall average) are my choice; moving them changes how many days fall in each group.
- **One traveler, one summer.** This is a personal dataset, not a representative sample of any country's transit system. Fares reflect 2026 prices and tourist-accessible options.
- **Exchange rates.** Daily conversions use public historical rates and rounding; small differences are possible.
- **Ride time only.** Waiting, which is a large part of travel in some regions, is not measured.

## Reproduce it

1. Open `transit_rides.db` in [DB Browser for SQLite](https://sqlitebrowser.org/) (File → Open Database), **or** import both CSVs as UTF-8 with column names in the first line, as tables `europe` and `central_asia`, and run the build script in `queries/` to create the combined `rides` table.
2. Run the queries in `queries/` in the Execute SQL tab. Highlight one query and press Ctrl+Return to run it on its own.
3. Every analysis query filters on `include_in_analysis = 'yes'`.
4. The Tableau charts use an export of the `rides` table and the daily results from query 4. The calculations for charts 2 and 3 (`Avg confirmed`, `USD per hour`, and the rank fields) are built inside Tableau.

## Repository structure

```
.
├── README.md
├── DATA_DICTIONARY.md
├── data/
│   ├── Europe_rides.csv
│   └── Central_Asia_rides.csv
├── database/
│   └── transit_rides.db
├── queries/
│   ├── 00_build_rides_table.sql
│   ├── 01_fare_by_mode.sql
│   ├── 02_estimated_vs_confirmed.sql
│   ├── 03_rank_per_ride_vs_per_hour.sql
│   └── 04_money_vs_time_by_day.sql
├── results/
│   └── (exported query results as CSV)
└── charts/
    ├── 01_avg_fare_by_mode.png
    ├── 02_estimated_vs_confirmed_dumbbell.png
    ├── 03_rank_per_ride_vs_per_hour_slope.png
    ├── 04_money_vs_time_calendar_heatmap.png
    └── 05_dashboard_overview.png
```
