import Foundation

struct Buoy: Identifiable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    
    static let sfBuoys = [
        Buoy(id: "46026", name: "San Francisco", latitude: 37.759, longitude: -122.833),
        Buoy(id: "46237", name: "San Francisco Bar", latitude: 37.786, longitude: -122.634),
        Buoy(id: "46214", name: "Point Reyes", latitude: 37.946, longitude: -123.470),
        Buoy(id: "46013", name: "Bodega Bay", latitude: 38.238, longitude: -123.307),
        Buoy(id: "46012", name: "Half Moon Bay", latitude: 37.363, longitude: -122.881)
    ]
    
    // Default to San Francisco Bar buoy as in the Python script
    static let defaultBuoy = Buoy(id: "46237", name: "San Francisco Bar", latitude: 37.786, longitude: -122.634)
}

struct TideStation: Identifiable, Equatable {
    let id: String
    let name: String
    var latitude: Double?
    var longitude: Double?
    
    static let predefinedStations = [
        TideStation(id: "9414290", name: "San Francisco, CA", latitude: 37.8063, longitude: -122.4659),
        TideStation(id: "9414750", name: "Alameda, CA", latitude: 37.7717, longitude: -122.2992),
        TideStation(id: "9415020", name: "Point Reyes, CA", latitude: 38.0012, longitude: -122.9761),
        TideStation(id: "9413450", name: "Monterey, CA", latitude: 36.6050, longitude: -121.8879),
        TideStation(id: "9410170", name: "San Diego, CA", latitude: 32.7142, longitude: -117.1736),
        TideStation(id: "9410230", name: "La Jolla, CA", latitude: 32.8669, longitude: -117.2571),
        TideStation(id: "9411340", name: "Santa Barbara, CA", latitude: 34.4080, longitude: -119.6857),
        TideStation(id: "9412110", name: "Port San Luis, CA", latitude: 35.1767, longitude: -120.7600)
    ]
    
    static let defaultStation = TideStation(id: "9414290", name: "San Francisco, CA", latitude: 37.8063, longitude: -122.4659)
}

struct BuoyData: Identifiable {
    let id = UUID()
    let time: String
    let waveHeight: String
    let waveDirection: String
    let wavePeriod: String
    let windSpeed: String
    let windDirection: String
    let waterTemperature: String?
    
    var waveHeightFormatted: String {
        if waveHeight == "MM" || waveHeight == "N/A" {
            return "Data not available"
        } else {
            return "\(waveHeight) m"
        }
    }
    
    var waveDirectionFormatted: String {
        if waveDirection == "MM" || waveDirection == "N/A" {
            return "Data not available"
        } else {
            return "\(waveDirection)° (\(DirectionHelper.degreesToCardinal(degrees: Double(waveDirection) ?? 0)))"
        }
    }
    
    var wavePeriodFormatted: String {
        if wavePeriod == "MM" || wavePeriod == "N/A" {
            return "Data not available"
        } else {
            return "\(wavePeriod) sec"
        }
    }
    
    var windSpeedFormatted: String {
        if windSpeed == "MM" || windSpeed == "N/A" {
            return "Data not available"
        } else {
            return "\(windSpeed) m/s"
        }
    }
    
    var windDirectionFormatted: String {
        if windDirection == "MM" || windDirection == "N/A" {
            return "Data not available"
        } else if let degrees = Double(windDirection) {
            return "\(windDirection)° (\(DirectionHelper.degreesToCardinal(degrees: degrees)))"
        } else {
            return windDirection
        }
    }
    
    var waterTemperatureFormatted: String {
        guard let temp = waterTemperature else { return "N/A" }
        if temp == "MM" || temp == "N/A" {
            return "Data not available"
        } else {
            return "\(temp)°C"
        }
    }
}

struct TideData: Identifiable {
    let id = UUID()
    let time: String
    let height: String
    let type: String
    
    var typeFormatted: String {
        return type == "H" ? "High" : "Low"
    }
}
