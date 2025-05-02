#!/usr/bin/env python3
"""
Minimal San Francisco Wave Forecast Script
Fetches wave data from NOAA buoy station 46237 (San Francisco Bar)
"""
import requests
from datetime import datetime

# Constants
BUOY_ID = "46237"
BUOY_NAME = "San Francisco Bar"
DIRECTIONS = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", 
              "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]

def get_direction(deg):
    """Convert degrees to cardinal direction"""
    try:
        return DIRECTIONS[round(float(deg) / 22.5) % 16]
    except:
        return "Unknown"

def format_value(value, unit="", is_direction=False):
    """Format a value for display"""
    if value in ['MM', 'N/A']:
        return "Data not available"
    if is_direction:
        return f"{value}° ({get_direction(value)})"
    return f"{value} {unit}"

# Main script
print(f"San Francisco Wave Forecast - Station {BUOY_ID} ({BUOY_NAME})")
print("=" * 60)

# Get current conditions
print("\nFetching current sea conditions...")
try:
    response = requests.get(f"https://www.ndbc.noaa.gov/data/realtime2/{BUOY_ID}.txt")
    if response.status_code == 200:
        lines = response.text.strip().split('\n')
        if len(lines) >= 3:
            headers = lines[0].replace('#', '').split()
            values = lines[2].split()
            
            # Create data dictionary
            data = {headers[i]: values[i] for i in range(min(len(headers), len(values)))}
            
            print(f"\n===== CURRENT SEA CONDITIONS AT {BUOY_NAME} BUOY ({BUOY_ID}) =====")
            print(f"Date/Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            print(f"Wave Height: {format_value(data.get('WVHT', 'N/A'), 'm')}")
            print(f"Dominant Wave Period: {format_value(data.get('DPD', 'N/A'), 'sec')}")
            print(f"Average Wave Period: {format_value(data.get('APD', 'N/A'), 'sec')}")
            print(f"Wave Direction: {format_value(data.get('MWD', 'N/A'), '', True)}")
            print(f"Wind Speed: {format_value(data.get('WSPD', 'N/A'), 'm/s')}")
            print(f"Wind Direction: {format_value(data.get('WDIR', 'N/A'), '', True)}")
            print(f"Water Temperature: {format_value(data.get('WTMP', 'N/A'), '°C')}")
except Exception as e:
    print(f"Error fetching current conditions: {e}")

# Get recent readings
print("\nFetching recent wave data...")
try:
    response = requests.get(f"https://www.ndbc.noaa.gov/data/realtime2/{BUOY_ID}.spec")
    if response.status_code == 200:
        lines = response.text.strip().split('\n')
        if len(lines) > 2:
            headers = lines[0].replace('#', '').split()
            print("\n===== RECENT WAVE READINGS =====")
            
            # Show last 3 readings
            for i in range(2, min(5, len(lines))):
                values = lines[i].split()
                if len(values) < len(headers):
                    continue
                
                # Create data dictionary
                data = {headers[j]: values[j] for j in range(min(len(headers), len(values)))}
                
                # Display the reading
                time_str = f"{data.get('YY', '')}-{data.get('MM', '')}-{data.get('DD', '')} {data.get('hh', '')}:{data.get('mm', '')}"
                print(f"\nReading {i-1}: {time_str}")
                print(f"Wave Height: {format_value(data.get('WVHT', 'N/A'), 'm')}")
                print(f"Wave Direction: {format_value(data.get('MWD', 'N/A'), '', True)}")
                # Use SwP (Swell Period) as it's typically closest to the dominant period
                print(f"Wave Period: {format_value(data.get('SwP', 'N/A'), 'sec')} (Swell Period)")
except Exception as e:
    print(f"Error fetching recent wave data: {e}")

print("\nNote: If data is showing as not available, it may be temporarily unavailable from NOAA.")
