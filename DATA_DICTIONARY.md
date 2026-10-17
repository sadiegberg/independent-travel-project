# Data Dictionary

Applies to `Europe_rides.csv` and `Central_Asia_rides.csv`. Both files have the same 18 columns in the same order. Each row is one ride leg (one ticket or one vehicle).

## Columns

| # | Column | Type | Description | Values / format |
|---|---|---|---|---|
| 1 | `country` | text | Country where the ride started (departure country) | e.g., Albania, Austria, Kyrgyzstan |
| 2 | `from_city` | text | City or locality where the ride started | Local spelling with accents, e.g., Shkodër, Tiranë |
| 3 | `to_city` | text | City or locality where the ride ended | Same as above. Same value as `from_city` for rides within one city |
| 4 | `date` | date (text) | Date of the ride | `M/D/YYYY`, e.g., `7/11/2026` |
| 5 | `mode` | text | Type of vehicle or transport | See [Modes](#modes) |
| 6 | `operator` | text | Company or service that ran the ride | e.g., Wiener Linien, FlixBus, Arriva; `private` for rides not run by a business; `unknown` if I could not identify it |
| 7 | `booking_id` | text | Links legs that were bought together | Operator code + day and month of the first leg, e.g., `SKY-1706`. Blank for standalone rides |
| 8 | `fare_local` | number | Fare in the currency I paid | Two decimals. Blank if there is no fare (bundled, included in lodging, or given by someone else) |
| 9 | `currency` | text | Currency of `fare_local` | ISO code, e.g., EUR, USD, ALL, KZT, KGS, UZS, AMD |
| 10 | `fare_usd` | number | Fare converted to US dollars at the ride-date exchange rate | Two decimals. Blank when `fare_local` is blank |
| 11 | `estimated_fare` | text | Whether the fare is an estimate | `yes` = reconstructed from published rates or memory; `no` = known from a receipt, app, or statement. Blank when there is no fare |
| 12 | `duration_min` | integer | In-vehicle ride time in minutes | Excludes waiting, check-in, and transfers unless noted. Blank for bundled legs without their own time |
| 13 | `estimated_duration` | text | Whether the duration is an estimate | `yes` = from a schedule, route guide, or memory; `no` = known or timed. Blank when `duration_min` is blank |
| 14 | `payment` | text | How I paid | See [Payment values](#payment-values) |
| 15 | `payment_detail` | text | Channel or detail of the payment | See [Payment values](#payment-values) |
| 16 | `estimated_payment` | text | Whether the payment method is an estimate | `yes` / `no` |
| 17 | `notes` | text | Free-text context | Bundled prices, rates used, fees, uncertainty, and other circumstances |
| 18 | `include_in_analysis` | text | Whether the row counts in the SQL analysis | `yes` / `no` |

## Modes

| Value | Meaning |
|---|---|
| `bus` | Scheduled or intercity bus or coach, including city buses |
| `metro` | Underground or subway rail |
| `tram` | Street-running rail |
| `train` | Intercity or regional rail |
| `flight` | Air travel |
| `ferry` | Scheduled passenger or car ferry |
| `boat` | Other boat, including private boats |
| `shuttle` | Private van or minibus transfer (hostel or tour operator transfers) |
| `marshrutka` | Shared minibus that leaves when full (called a *furgon* in Albania) |
| `taxi` | Taxi or ride-hailing |
| `charter van` | Van hired for a group or route |
| `horse` | Horseback ride |
| `gondola` | Cable car or gondola |
| `bike` | Rented bicycle |
| `informal ride` | Unscheduled local ride arranged on the spot |
| `hitchhiked` | Ride given by a stranger |

## Payment values

**`payment`** (how I paid):

| Value | Meaning |
|---|---|
| `card` | Debit or credit card |
| `cash` | Cash |
| `contactless` | Tap payment with a card or phone wallet |
| `app` | Paid inside a transport or booking app |
| `card + cash` | Part paid by card, part by cash |
| `none` | No payment for this ride (free, gifted, or included) |

**`payment_detail`** (channel or method detail), examples: `Apple Pay`, `card in app`, `online`, `ticket machine`, `ticket counter`, `terminal counter`, `paid driver`, `paid on board`, `contactless`, `cash`, `card`, `none`.

## Blank cells

A blank is meaningful in several columns. It does not always mean "missing":

- `fare_local`, `fare_usd`, `estimated_fare`: blank when there is no separate fare (a package leg, a ride included in lodging, or a ride given by someone else).
- `duration_min`, `estimated_duration`: blank for package legs that share a single combined time.
- `booking_id`: blank for rides that were bought on their own.

## Fields added in the SQLite database (`transit_rides.db`)

The `rides` table combines both CSVs and adds or changes the following:

| Column | Type | Description |
|---|---|---|
| `ride_id` | integer | Unique ID for each row (primary key) |
| `region` | text | `Europe` or `Central Asia`, from the source file |
| `ride_date` | text | The `date` column converted to ISO format, `YYYY-MM-DD`, so it sorts and filters correctly |
| `fare_local`, `fare_usd` | real | Stored as numbers; blanks become NULL |
| `duration_min` | integer | Stored as a number; blanks become NULL |
| All other columns | text | Same as the CSVs; empty `booking_id`, `currency`, `estimated_fare`, `estimated_duration`, and `notes` become NULL |

## Conventions

- **Dates** are `M/D/YYYY` in the CSVs and `YYYY-MM-DD` in the database.
- **Encoding** is UTF-8. The `_import` versions have no byte-order mark; the original CSVs include one for Excel.
- **Exchange rates:** daily rates for the ride date; weekend rides use the last weekday rate. Prepaid tickets noted in `notes` use the purchase-date rate.
- **Place names** use local spellings with accents where the place has them.
