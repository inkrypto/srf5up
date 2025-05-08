# SF Wave Tides iOS App

This iOS app displays San Francisco wave forecasts with tide information from NOAA data sources.

## Project Structure

The app is organized using MVVM architecture:

- **Models**: Data structures for buoys, wave conditions, and tides
- **Views**: UI components for displaying the data
- **ViewModels**: Business logic for data fetching and manipulation
- **Services**: Network services for API communication
- **Helpers**: Utility functions and extensions

## Setting Up the Project in Xcode

1. Launch Xcode
2. Select "File" > "New" > "Project..."
3. Choose "App" template under iOS
4. Set the Product Name to "SFWaveTides"
5. Choose SwiftUI for Interface, and select iOS for Platform
6. Complete the setup process and point to the SFWaveTides directory
7. Once the project is created, add the source files from their respective directories:
   - Add models from the Models directory
   - Add views from the Views directory
   - Add services from the Services directory
   - Add view models from the ViewModels directory
   - Add helpers from the Helpers directory

## App Features

- Current sea conditions display
- Wave forecast data for the next few hours
- High and low tide information for San Francisco
- Buoy selection with map interface

## Data Sources

- NOAA National Data Buoy Center (NDBC) for wave data
- NOAA Tides and Currents API for tide information

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Privacy

The app includes NSAppTransportSecurity settings to allow HTTP connections to NOAA data sources.
