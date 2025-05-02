#!/usr/bin/env python3
"""
San Francisco Wave Forecast Script - Simplified Version
Fetches wave data from NOAA buoy station 46237 (San Francisco Bar)
"""

import requests
from datetime import datetime

# San Francisco Bar buoy ID
BUOY_ID = "46237"
BUOY_NAME = "San Francisco Bar"

def get_direction_text(degrees):
    """Convert degrees to cardinal direction"""
    directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", 
                  "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    try:
        index = round(float(degrees) / 22.5) % 16
        return directions[index]
    except:
        return "Unknown"

def fetch_and_parse_data(url, skip_lines=2):
    """Fetch and parse data from NDBC"""
    try:
        response = requests.get(url)
        if response.status_code != 200:
            return None
        
        lines = response.text.strip().split('\n')
        if len(lines) <= skip_lines:
            return None
            
        headers = lines[0].replace('#', '').split()
        values = lines[skip_lines].split()
        
        data = {}
        for i, header in enumerate(headers):
            if i < len(values):
                data[header] = values[i]
        return data
    except Exception as e:
        print(f"Error fetching data: {e}")
        return None

def display_value(label, value, unit="", is_direction=False):
    """Display a value with proper formatting"""
    if value == 'MM' or value == 'N/A':
        print(f"{label}: Data not available")
    else:
        if is_direction:
            print(f"{label}: {value}° ({get_direction_text(value)})")
        else:
            print(f"{label}: {value} {unit}")

def main():
    """Main function to run the script"""
    print(f"San Francisco Wave Forecast - Station {BUOY_ID} ({BUOY_NAME})")
    print("=" * 60)
    
    # Get current conditions
    print("\nFetching current sea conditions...")
    current_url = f"https://www.ndbc.noaa.gov/data/realtime2/{BUOY_ID}.txt"
    current_data = fetch_and_parse_data(current_url)
    
    if current_data:
        print(f"\n===== CURRENT SEA CONDITIONS AT {BUOY_NAME} BUOY ({BUOY_ID}) =====")
        print(f"Date/Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        display_value("Wave Height", current_data.get('WVHT', 'N/A'), "m")
        display_value("Dominant Wave Period", current_data.get('DPD', 'N/A'), "sec")
        display_value("Average Wave Period", current_data.get('APD', 'N/A'), "sec")
        display_value("Wave Direction", current_data.get('MWD', 'N/A'), "", True)
        display_value("Wind Speed", current_data.get('WSPD', 'N/A'), "m/s")
        display_value("Wind Direction", current_data.get('WDIR', 'N/A'), "", True)
        display_value("Water Temperature", current_data.get('WTMP', 'N/A'), "°C")
    else:
        print("No current condition data available.")
    
    # Get recent readings
    print("\nFetching recent wave data...")
    spec_url = f"https://www.ndbc.noaa.gov/data/realtime2/{BUOY_ID}.spec"
    
    try:
        response = requests.get(spec_url)
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
                    
                    # Create a dictionary for this data point
                    data = {}
                    for j, header in enumerate(headers):
                        if j < len(values):
                            data[header] = values[j]
                    
                    # Display the reading
                    time_str = f"{data.get('YY', '')}-{data.get('MM', '')}-{data.get('DD', '')} {data.get('hh', '')}:{data.get('mm', '')}"
                    print(f"\nReading {i-1}: {time_str}")
                    display_value("Wave Height", data.get('WVHT', 'N/A'), "m")
                    display_value("Wave Direction", data.get('MWD', 'N/A'), "", True)
                    display_value("Wave Period", data.get('DPD', 'N/A'), "sec")
        else:
            print("No recent wave data available.")
    except Exception as e:
        print(f"Error fetching recent wave data: {e}")
    
    print("\nNote: If data is showing as not available, it may be temporarily unavailable from NOAA.")

if __name__ == "__main__":
    main()
