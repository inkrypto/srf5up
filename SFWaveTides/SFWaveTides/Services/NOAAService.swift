import Foundation
import Combine

class NOAAService: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Buoy Data
    func fetchBuoyData(buoyId: String) -> AnyPublisher<BuoyData, Error> {
        let url = URL(string: "https://www.ndbc.noaa.gov/data/realtime2/\(buoyId).txt")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> BuoyData in
                guard let dataString = String(data: data, encoding: .utf8) else {
                    throw URLError(.badServerResponse)
                }
                
                return try self.parseBuoyData(dataString)
            }
            .eraseToAnyPublisher()
    }
    
    private func parseBuoyData(_ dataText: String) throws -> BuoyData {
        let lines = dataText.components(separatedBy: .newlines)
        guard lines.count >= 3 else {
            throw NSError(domain: "NOAAService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])
        }
        
        // Extract headers and most recent data
        let headers = lines[0].replacingOccurrences(of: "#", with: "").components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let values = lines[2].components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        // Create a dictionary of the data
        var data = [String: String]()
        for (i, header) in headers.enumerated() {
            if i < values.count {
                data[header] = values[i]
            }
        }
        
        // Extract the values we care about
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return BuoyData(
            time: dateFormatter.string(from: now),
            waveHeight: data["WVHT"] ?? "N/A",
            waveDirection: data["MWD"] ?? "N/A",
            wavePeriod: data["DPD"] ?? data["APD"] ?? "N/A",
            windSpeed: data["WSPD"] ?? "N/A",
            windDirection: data["WDIR"] ?? "N/A",
            waterTemperature: data["WTMP"]
        )
    }
    
    // MARK: - Wave Forecast
    func fetchWaveForecast(buoyId: String) -> AnyPublisher<[BuoyData], Error> {
        let url = URL(string: "https://www.ndbc.noaa.gov/data/realtime2/\(buoyId).spec")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> [BuoyData] in
                guard let dataString = String(data: data, encoding: .utf8) else {
                    throw URLError(.badServerResponse)
                }
                
                return try self.parseSpectralData(dataString)
            }
            .catch { error -> AnyPublisher<[BuoyData], Error> in
                // Try alternative API if spectral data fails
                return self.fetchAlternativeForecast(buoyId: buoyId)
            }
            .eraseToAnyPublisher()
    }
    
    private func parseSpectralData(_ dataText: String) throws -> [BuoyData] {
        let lines = dataText.components(separatedBy: .newlines)
        guard lines.count >= 7 else {
            throw NSError(domain: "NOAAService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Insufficient data points for forecast"])
        }
        
        // Extract headers
        let headers = lines[0].replacingOccurrences(of: "#", with: "").components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        var forecasts = [BuoyData]()
        
        // Use the most recent 5 data points
        for i in 2..<min(7, lines.count) {
            let values = lines[i].components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard values.count >= headers.count else { continue }
            
            // Create a dictionary for this data point
            var data = [String: String]()
            for (j, header) in headers.enumerated() {
                if j < values.count {
                    data[header] = values[j]
                }
            }
            
            // Format date and time
            let year = data["YY"] ?? ""
            let month = data["MM"] ?? ""
            let day = data["DD"] ?? ""
            let hour = data["hh"] ?? ""
            let minute = data["mm"] ?? ""
            let timeStr = "\(year)-\(month)-\(day) \(hour):\(minute)"
            
            // Create forecast entry
            let forecast = BuoyData(
                time: timeStr,
                waveHeight: data["WVHT"] ?? "N/A",
                waveDirection: data["MWD"] ?? "N/A",
                wavePeriod: data["DPD"] ?? data["APD"] ?? "N/A",
                windSpeed: "N/A",  // Not available in spec data
                windDirection: "N/A",  // Not available in spec data
                waterTemperature: nil
            )
            
            forecasts.append(forecast)
        }
        
        return forecasts
    }
    
    private func fetchAlternativeForecast(buoyId: String) -> AnyPublisher<[BuoyData], Error> {
        // San Francisco coordinates (approximate)
        let sfLat = 37.7749
        let sfLong = -122.4194
        
        let url = URL(string: "https://marine.weather.gov/MapClick.php?lat=\(sfLat)&lon=\(sfLong)&FcstType=json")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MarineForecast.self, decoder: JSONDecoder())
            .tryMap { data -> [BuoyData] in
                var forecasts = [BuoyData]()
                
                // Extract relevant forecast data
                for i in 0..<min(data.time.startPeriodName.count, 5) {
                    let forecast = BuoyData(
                        time: data.time.startPeriodName[i],
                        waveHeight: "N/A",  // Marine forecast doesn't always include wave height
                        waveDirection: "N/A",
                        wavePeriod: "N/A",
                        windSpeed: data.data.weather[i],
                        windDirection: data.data.text[i],
                        waterTemperature: nil
                    )
                    forecasts.append(forecast)
                }
                
                return forecasts
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Tide Data
    func fetchTideData(stationId: String = TideStation.defaultStation.id, date: String = "today") -> AnyPublisher<[TideData], Error> {
        let url = URL(string: "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?date=\(date)&station=\(stationId)&product=predictions&datum=MLLW&time_zone=lst_ldt&units=english&format=json&interval=hilo")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TideResponse.self, decoder: JSONDecoder())
            .map { response in
                return response.predictions.map { prediction in
                    TideData(
                        time: prediction.t,
                        height: prediction.v,
                        type: prediction.type
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Response Models
struct MarineForecast: Decodable {
    struct Time: Decodable {
        let startPeriodName: [String]
    }
    
    struct Data: Decodable {
        let weather: [String]
        let text: [String]
    }
    
    let time: Time
    let data: Data
}

struct TideResponse: Decodable {
    struct Prediction: Decodable {
        let t: String
        let v: String
        let type: String
    }
    
    let predictions: [Prediction]
}
