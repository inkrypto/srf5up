#!/usr/bin/env python3
"""
San Francisco Wave Forecast Script

This script fetches wave forecast data from the NOAA National Data Buoy Center (NDBC)
for buoys near San Francisco and displays the relevant information.
"""

import requests
import json
import sys
from datetime import datetime
import xml.etree.ElementTree as ET
from urllib.request import urlopen
from math import radians, cos, sin, asin, sqrt

# San Francisco coordinates (approximate)
SF_LAT = 37.7749
SF_LONG = -122.4194

# List of buoys near San Francisco
# These are the most relevant NDBC buoys near San Francisco Bay
SF_BUOYS = [
    {"id": "46026", "name": "San Francisco", "lat": 37.759, "lon": -122.833},
    {"id": "46237", "name": "San Francisco Bar", "lat": 37.786, "lon": -122.634},
    {"id": "46214", "name": "Point Reyes", "lat": 37.946, "lon": -123.470},
    {"id": "46013", "name": "Bodega Bay", "lat": 38.238, "lon": -123.307},
    {"id": "46012", "name": "Half Moon Bay", "lat": 37.363, "lon": -122.881},
]

def haversine(lon1, lat1, lon2, lat2):
    """
    Calculate the great circle distance between two points 
    on the earth (specified in decimal degrees)
    """
    # Convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    
    # Haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    r = 6371  # Radius of earth in kilometers
    return c * r

def find_closest_buoy():
    """Find the closest buoy to San Francisco"""
    closest_buoy = None
    min_distance = float('inf')
    
    for buoy in SF_BUOYS:
        distance = haversine(SF_LONG, SF_LAT, buoy["lon"], buoy["lat"])
        if distance < min_distance:
            min_distance = distance
            closest_buoy = buoy
    
    return closest_buoy, min_distance

def get_buoy_data(buoy_id):
    """Fetch the latest data from the specified buoy"""
    # NDBC data endpoint for the latest observations (realtime2 format)
    url = f"https://www.ndbc.noaa.gov/data/realtime2/{buoy_id}.txt"
    
    try:
        response = requests.get(url)
        if response.status_code == 200:
            return parse_buoy_data(response.text)
        else:
            print(f"Error fetching data: HTTP {response.status_code}")
            return None
    except Exception as e:
        print(f"Error fetching buoy data: {e}")
        return None

def parse_buoy_data(data_text):
    """Parse the text data from NDBC"""
    lines = data_text.strip().split('\n')
    if len(lines) < 3:  # Need at least headers, units, and one data line
        return None
    
    # Extract headers and most recent data (3rd line, after headers and units)
    headers = lines[0].replace('#', '').split()
    values = lines[2].split()  # First data line (most recent)
    
    # Create a dictionary of the data
    data = {}
    for i, header in enumerate(headers):
        if i < len(values):
            data[header] = values[i]
    
    return data

def get_wave_forecast(buoy_id):
    """Get wave forecast data for the specified buoy"""
    # Use spectral data for more detailed wave information
    url = f"https://www.ndbc.noaa.gov/data/realtime2/{buoy_id}.spec"
    
    try:
        response = requests.get(url)
        if response.status_code == 200:
            return parse_spectral_data(response.text)
        else:
            # Try alternative API
            return get_alternative_forecast(buoy_id)
    except Exception as e:
        print(f"Error fetching forecast data: {e}")
        return get_alternative_forecast(buoy_id)

def parse_spectral_data(data_text):
    """Parse the spectral data from NDBC to create a forecast"""
    try:
        lines = data_text.strip().split('\n')
        if len(lines) < 10:  # Need enough data points for a forecast
            return None
        
        # Extract headers and data
        headers = lines[0].replace('#', '').split()
        
        forecasts = []
        # Use the most recent 5 data points to create a "forecast"
        for i in range(2, min(7, len(lines))):
            values = lines[i].split()
            if len(values) < len(headers):
                continue
                
            # Create a dictionary for this data point
            data = {}
            for j, header in enumerate(headers):
                if j < len(values):
                    data[header] = values[j]
            
            # Format date and time
            year = data.get('YY', '')
            month = data.get('MM', '')
            day = data.get('DD', '')
            hour = data.get('hh', '')
            minute = data.get('mm', '')
            time_str = f"{year}-{month}-{day} {hour}:{minute}"
            
            # Create forecast entry
            forecast = {
                'time': time_str,
                'wave_height': data.get('WVHT', 'N/A'),
                'wave_direction': data.get('MWD', 'N/A'),
                'wave_period': data.get('DPD', 'N/A') if 'DPD' in data else data.get('APD', 'N/A'),
                'wind_speed': 'N/A',  # Not available in spec data
                'wind_direction': 'N/A'  # Not available in spec data
            }
            forecasts.append(forecast)
        
        return forecasts
    except Exception as e:
        print(f"Error parsing spectral data: {e}")
        return None

def get_alternative_forecast(buoy_id):
    """Get forecast data from an alternative source if NDBC forecast is unavailable"""
    # Using NOAA Marine Forecast API as an alternative
    url = f"https://marine.weather.gov/MapClick.php?lat={SF_LAT}&lon={SF_LONG}&FcstType=json"
    
    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            forecasts = []
            
            # Extract relevant forecast data
            for i in range(min(len(data.get('time', {}).get('startPeriodName', [])), 5)):
                forecast = {
                    'time': data['time']['startPeriodName'][i],
                    'wave_height': 'N/A',  # Marine forecast doesn't always include wave height
                    'wave_direction': 'N/A',
                    'wave_period': 'N/A',
                    'wind_speed': data['data']['weather'][i],
                    'wind_direction': data['data']['text'][i]
                }
                forecasts.append(forecast)
            
            return forecasts
        else:
            print(f"Error fetching alternative forecast: HTTP {response.status_code}")
            return None
    except Exception as e:
        print(f"Error fetching alternative forecast: {e}")
        return None

def display_current_conditions(buoy, data):
    """Display current sea conditions from buoy data"""
    if not data:
        print("No current condition data available.")
        return
    
    print(f"\n===== CURRENT SEA CONDITIONS AT {buoy['name']} BUOY ({buoy['id']}) =====")
    print(f"Date/Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Extract and display wave data if available
    wave_height = data.get('WVHT', 'N/A')
    if wave_height != 'N/A' and wave_height != 'MM':
        print(f"Wave Height: {wave_height} m")
    elif wave_height == 'MM':
        print(f"Wave Height: Data not available")
    else:
        print(f"Wave Height: N/A")
    
    dom_period = data.get('DPD', 'N/A')
    if dom_period != 'N/A' and dom_period != 'MM':
        print(f"Dominant Wave Period: {dom_period} sec")
    elif dom_period == 'MM':
        print(f"Dominant Wave Period: Data not available")
    else:
        print(f"Dominant Wave Period: N/A")
    
    avg_period = data.get('APD', 'N/A')
    if avg_period != 'N/A' and avg_period != 'MM':
        print(f"Average Wave Period: {avg_period} sec")
    elif avg_period == 'MM':
        print(f"Average Wave Period: Data not available")
    else:
        print(f"Average Wave Period: N/A")
    
    wave_dir = data.get('MWD', 'N/A')
    if wave_dir != 'N/A' and wave_dir != 'MM':
        print(f"Wave Direction: {wave_dir}° ({get_direction_text(float(wave_dir))})")
    elif wave_dir == 'MM':
        print(f"Wave Direction: Data not available")
    else:
        print(f"Wave Direction: N/A")
    
    # Wind data
    wind_speed = data.get('WSPD', 'N/A')
    if wind_speed != 'N/A' and wind_speed != 'MM':
        print(f"Wind Speed: {wind_speed} m/s")
    elif wind_speed == 'MM':
        print(f"Wind Speed: Data not available")
    else:
        print(f"Wind Speed: N/A")
    
    wind_dir = data.get('WDIR', 'N/A')
    if wind_dir != 'N/A' and wind_dir != 'MM':
        print(f"Wind Direction: {wind_dir}° ({get_direction_text(float(wind_dir))})")
    elif wind_dir == 'MM':
        print(f"Wind Direction: Data not available")
    else:
        print(f"Wind Direction: N/A")
    
    # Water temperature if available
    water_temp = data.get('WTMP', 'N/A')
    if water_temp != 'N/A' and water_temp != 'MM':
        print(f"Water Temperature: {water_temp}°C")
    elif water_temp == 'MM':
        print(f"Water Temperature: Data not available")
    else:
        print(f"Water Temperature: N/A")

def get_direction_text(degrees):
    """Convert degrees to cardinal direction"""
    directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", 
                  "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    index = round(degrees / 22.5) % 16
    return directions[index]

def display_forecast(forecasts):
    """Display wave forecast data"""
    if not forecasts:
        print("No forecast data available.")
        return
    
    print("\n===== RECENT WAVE DATA (LAST 5 READINGS) =====")
    
    for i, forecast in enumerate(forecasts[:5]):  # Show last 5 data points
        print(f"\nReading {i+1}: {forecast['time']}")
        
        # Wave Height
        wave_height = forecast['wave_height']
        if wave_height != 'N/A' and wave_height != 'MM':
            print(f"Wave Height: {wave_height} m")
        elif wave_height == 'MM':
            print(f"Wave Height: Data not available")
        else:
            print(f"Wave Height: N/A")
        
        # Wave Direction
        wave_dir = forecast['wave_direction']
        if wave_dir != 'N/A' and wave_dir != 'MM':
            try:
                direction = get_direction_text(float(wave_dir))
                print(f"Wave Direction: {wave_dir}° ({direction})")
            except:
                print(f"Wave Direction: {wave_dir}")
        elif wave_dir == 'MM':
            print(f"Wave Direction: Data not available")
        else:
            print(f"Wave Direction: N/A")
        
        # Wave Period
        wave_period = forecast['wave_period']
        if wave_period != 'N/A' and wave_period != 'MM':
            print(f"Wave Period: {wave_period} sec")
        elif wave_period == 'MM':
            print(f"Wave Period: Data not available")
        else:
            print(f"Wave Period: N/A")
        
        # Wind Speed
        wind_speed = forecast['wind_speed']
        if wind_speed != 'N/A' and wind_speed != 'MM':
            print(f"Wind Speed: {wind_speed}")
        elif wind_speed == 'MM':
            print(f"Wind Speed: Data not available")
        elif wind_speed != 'N/A':
            print(f"Wind Speed: {wind_speed}")
        
        # Wind Direction
        wind_dir = forecast['wind_direction']
        if wind_dir != 'N/A' and wind_dir != 'MM':
            print(f"Wind Direction: {wind_dir}")
        elif wind_dir == 'MM':
            print(f"Wind Direction: Data not available")
        elif wind_dir != 'N/A':
            print(f"Wind Direction: {wind_dir}")

def main():
    """Main function to run the script"""
    print("San Francisco Wave Forecast - Station 46237 (San Francisco Bar)")
    print("==============================================================")
    
    # Use San Francisco Bar buoy directly (station 46237)
    sf_bar_buoy = {"id": "46237", "name": "San Francisco Bar", "lat": 37.786, "lon": -122.634}
    
    # Get current conditions
    print("\nFetching current sea conditions...")
    buoy_data = get_buoy_data(sf_bar_buoy['id'])
    display_current_conditions(sf_bar_buoy, buoy_data)
    
    # Get recent wave data
    print("\nFetching recent wave data...")
    wave_data = get_wave_forecast(sf_bar_buoy['id'])
    display_forecast(wave_data)
    
    print("\nNote: If data is showing as N/A, it may be temporarily unavailable from NOAA.")

if __name__ == "__main__":
    main()
