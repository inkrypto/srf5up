# San Francisco Wave Forecast Script

This Python script fetches wave data from NOAA buoy station 46237 (San Francisco Bar) and displays the current conditions and recent readings.

## Features

- Specifically targets the San Francisco Bar buoy (station 46237)
- Fetches current sea conditions including:
  - Wave height
  - Wave period (dominant and average)
  - Wave direction
  - Wind speed and direction
  - Water temperature
- Displays the last 5 readings from the buoy to show recent wave patterns
- Properly handles missing data values (marked as "MM" in NOAA data)

## Requirements

- Python 3.6 or higher
- `requests` library

## Installation

1. Ensure you have Python installed
2. Install the required library:
   ```
   pip install requests
   ```

## Usage

Simply run the script:

```
python sf_wave_forecast.py
```

Or make it executable and run directly:

```
chmod +x sf_wave_forecast.py
./sf_wave_forecast.py
```

## How It Works

1. The script directly uses the San Francisco Bar buoy (station 46237)
2. It fetches the latest observational data from this buoy for current conditions
3. It retrieves recent wave readings from the buoy's spectral data file
4. It properly handles missing data values (marked as "MM" in NOAA data)
5. All data is displayed in a readable format in the terminal

## Data Sources

- NOAA National Data Buoy Center (NDBC) - Source for buoy data
  - Standard meteorological data: https://www.ndbc.noaa.gov/data/realtime2/[station_id].txt
  - Spectral wave data: https://www.ndbc.noaa.gov/data/realtime2/[station_id].spec

## Note

If data is showing as "N/A", it may be temporarily unavailable from the NOAA data sources. This can happen due to buoy maintenance, data transmission issues, or API limitations.
