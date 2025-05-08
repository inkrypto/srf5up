import Foundation

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
}
