import Foundation

// MARK: - Buoy Model
struct Buoy: Identifiable, Codable, Hashable {
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
    
    static let sfStationID = "9414290" // San Francisco tide station
    
    // Default to San Francisco Bar buoy (46237) as specified in sf_wave_forecast_minimal.py
    static let defaultBuoy = Buoy(id: "46237", name: "San Francisco Bar", latitude: 37.786, longitude: -122.634)
    
    // Get buoy by ID, or return default if not found
    static func getBuoyById(_ id: String) -> Buoy {
        return sfBuoys.first(where: { $0.id == id }) ?? defaultBuoy
    }
}

// MARK: - Buoy Data Model
struct BuoyData: Identifiable, Codable {
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
    
    // Simplified getters for Watch UI (shorter labels)
    var heightShort: String {
        if waveHeight == "MM" || waveHeight == "N/A" {
            return "N/A"
        } else {
            return "\(waveHeight)m"
        }
    }
    
    var periodShort: String {
        if wavePeriod == "MM" || wavePeriod == "N/A" {
            return "N/A"
        } else {
            return "\(wavePeriod)s"
        }
    }
}

// MARK: - Tide Data Model
struct TideData: Identifiable, Codable {
    let id = UUID()
    let time: String
    let height: String
    let type: String
    
    var typeFormatted: String {
        return type == "H" ? "High" : "Low"
    }
    
    var timeFormatted: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        
        if let date = inputFormatter.date(from: time) {
            return outputFormatter.string(from: date)
        }
        return time
    }
    
    // For watch UI - compact time display
    var timeShort: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm"
        
        if let date = inputFormatter.date(from: time) {
            return outputFormatter.string(from: date)
        }
        return time
    }
}

// MARK: - Helper Functions
struct DirectionHelper {
    static func degreesToCardinal(degrees: Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", 
                          "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        
        let index = Int(round(degrees / 22.5)) % 16
        return directions[index]
    }
    
    static func distanceBetween(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        // Convert to radians
        let lat1Rad = lat1 * .pi / 180
        let lon1Rad = lon1 * .pi / 180
        let lat2Rad = lat2 * .pi / 180
        let lon2Rad = lon2 * .pi / 180
        
        // Haversine formula
        let dlon = lon2Rad - lon1Rad
        let dlat = lat2Rad - lat1Rad
        let a = sin(dlat/2) * sin(dlat/2) + cos(lat1Rad) * cos(lat2Rad) * sin(dlon/2) * sin(dlon/2)
        let c = 2 * asin(sqrt(a))
        let r = 6371.0 // Radius of earth in kilometers
        
        return c * r
    }
    
    static func getTideTimeRemaining(_ tideTime: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let tideDate = dateFormatter.date(from: tideTime) else {
            return nil
        }
        
        let now = Date()
        let timeInterval = tideDate.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            return nil
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
