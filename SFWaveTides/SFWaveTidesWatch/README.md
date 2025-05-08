# SF Wave Tides - Apple Watch App

This is the Apple Watch companion app for the SF Wave Tides iOS application, providing glanceable information about San Francisco wave and tide conditions directly on your wrist.

## Features

- **Current Tide Information**: Shows the current tide level (high or low) with height and time
- **Next Tide Prediction**: Displays when the next tide will occur with countdown timer
- **Wave Conditions**: Current wave height, period, and direction at a glance
- **Buoy Selection**: Choose from multiple NOAA buoys near San Francisco
- **Watch Face Complication**: Tide information directly on your watch face

## Project Structure

The Watch app follows the SwiftUI lifecycle and is organized as follows:

### Shared Code
In the `Shared` directory:
- **Models.swift**: Data structures for buoys, wave conditions, and tides
- **NOAAService.swift**: Network service for fetching data from NOAA APIs
- **ForecastViewModel.swift**: Business logic and data management

### Watch App 
In the `Watch` directory:
- **SFWaveTidesApp.swift**: Main app entry point
- **ContentView.swift**: Root tab view controller
- **TideView.swift**: Current and next tide information
- **WaveConditionsView.swift**: Wave height, period, and other metrics
- **BuoySelectionView.swift**: Interface to select different buoys
- **ComplicationController.swift**: Watch face complication implementation

## Setting Up in Xcode

1. Launch Xcode
2. Select "File" > "New" > "Project..."
3. Choose "Watch App" template
4. Set the Product Name to "SFWaveTides"
5. Add the source files from their respective directories
6. Configure the Watch app target to include the necessary entitlements for networking

## Requirements

- watchOS 8.0+
- Xcode 14.0+
- Swift 5.5+

## Watch Face Integration

The app provides complications for various watch faces showing:
- Current tide type (high/low)
- Tide height
- Time until next tide change

To use:
1. Long-press on your watch face
2. Tap "Edit"
3. Select a complication slot
4. Choose "SF Wave Tides" from the list
5. Choose your preferred complication style

## Data Sources

- NOAA National Data Buoy Center (NDBC) for wave data
- NOAA Tides and Currents API for tide information

---

**Note:** This watch app is optimized for quick glances and minimal interaction, focusing on the most important information about current tide and wave conditions near San Francisco.
