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
    
    // MARK: - Tide Data
    func fetchTideData(stationId: String = Buoy.sfStationID, date: String = "today") -> AnyPublisher<[TideData], Error> {
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
struct TideResponse: Decodable {
    struct Prediction: Decodable {
        let t: String
        let v: String
        let type: String
    }
    
    let predictions: [Prediction]
}
