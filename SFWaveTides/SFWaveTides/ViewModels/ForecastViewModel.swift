import Foundation
import Combine

class ForecastViewModel: ObservableObject {
    private let noaaService = NOAAService()
    private var cancellables = Set<AnyCancellable>()
    
    // Published properties for the UI
    @Published var currentBuoyData: BuoyData?
    @Published var waveForecasts: [BuoyData] = []
    @Published var tideData: [TideData] = []
    @Published var selectedBuoy: Buoy = Buoy.defaultBuoy
    @Published var selectedTideStation: TideStation = TideStation.defaultStation
    @Published var customStationId: String = ""
    @Published var customStationName: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // UserDefaults keys
    private let selectedTideStationIdKey = "selectedTideStationId"
    private let selectedTideStationNameKey = "selectedTideStationName"
    private let customStationIdsKey = "customStationIds"
    private let customStationNamesKey = "customStationNames"
    
    // Custom user-added stations
    @Published var customTideStations: [TideStation] = []
    
    init() {
        // Load any saved tide station preferences
        loadSavedTideStations()
        
        // Initially load data for the default buoy
        loadAllData()
    }
    
    func loadAllData() {
        isLoading = true
        errorMessage = nil
        
        // Create a group for all three data fetches
        Publishers.Zip3(
            fetchCurrentBuoyData(),
            fetchWaveForecast(),
            fetchTideData()
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to load data: \(error.localizedDescription)"
                }
            },
            receiveValue: { _, _, _ in
                // All data has been updated through individual publishers
            }
        )
        .store(in: &cancellables)
    }
    
    func selectBuoy(_ buoy: Buoy) {
        selectedBuoy = buoy
        loadAllData()
    }
    
    func selectTideStation(_ station: TideStation) {
        selectedTideStation = station
        
        // Save selection to UserDefaults
        UserDefaults.standard.set(station.id, forKey: selectedTideStationIdKey)
        UserDefaults.standard.set(station.name, forKey: selectedTideStationNameKey)
        
        loadAllData()
    }
    
    func addCustomTideStation(id: String, name: String) {
        // Validate the station ID
        guard !id.isEmpty else {
            errorMessage = "Station ID cannot be empty"
            return
        }
        
        // Create a name if none provided
        let stationName = name.isEmpty ? "Custom Station \(id)" : name
        
        // Create new station
        let newStation = TideStation(id: id, name: stationName, latitude: nil, longitude: nil)
        
        // Check if it already exists
        if !customTideStations.contains(where: { $0.id == id }) {
            customTideStations.append(newStation)
            saveCustomStations()
        }
        
        // Select the new station
        selectTideStation(newStation)
        
        // Clear the input fields
        customStationId = ""
        customStationName = ""
    }
    
    func removeCustomTideStation(_ station: TideStation) {
        customTideStations.removeAll(where: { $0.id == station.id })
        saveCustomStations()
        
        // If we deleted the currently selected station, revert to default
        if selectedTideStation.id == station.id {
            selectTideStation(TideStation.defaultStation)
        }
    }
    
    private func loadSavedTideStations() {
        // Load custom stations
        if let savedIds = UserDefaults.standard.array(forKey: customStationIdsKey) as? [String],
           let savedNames = UserDefaults.standard.array(forKey: customStationNamesKey) as? [String],
           savedIds.count == savedNames.count {
            
            for i in 0..<savedIds.count {
                let station = TideStation(id: savedIds[i], name: savedNames[i], latitude: nil, longitude: nil)
                customTideStations.append(station)
            }
        }
        
        // Load selected station
        if let savedStationId = UserDefaults.standard.string(forKey: selectedTideStationIdKey),
           let savedStationName = UserDefaults.standard.string(forKey: selectedTideStationNameKey) {
            
            // First check if it's a predefined station
            if let predefinedStation = TideStation.predefinedStations.first(where: { $0.id == savedStationId }) {
                selectedTideStation = predefinedStation
            } 
            // Then check if it's a custom station
            else if let customStation = customTideStations.first(where: { $0.id == savedStationId }) {
                selectedTideStation = customStation
            } 
            // If not found anywhere, create a new one with the saved data
            else {
                selectedTideStation = TideStation(id: savedStationId, name: savedStationName, latitude: nil, longitude: nil)
            }
        }
    }
    
    private func saveCustomStations() {
        let ids = customTideStations.map { $0.id }
        let names = customTideStations.map { $0.name }
        
        UserDefaults.standard.set(ids, forKey: customStationIdsKey)
        UserDefaults.standard.set(names, forKey: customStationNamesKey)
    }
    
    private func fetchCurrentBuoyData() -> AnyPublisher<BuoyData, Error> {
        return noaaService.fetchBuoyData(buoyId: selectedBuoy.id)
            .handleEvents(receiveOutput: { [weak self] data in
                self?.currentBuoyData = data
            })
            .eraseToAnyPublisher()
    }
    
    private func fetchWaveForecast() -> AnyPublisher<[BuoyData], Error> {
        return noaaService.fetchWaveForecast(buoyId: selectedBuoy.id)
            .handleEvents(receiveOutput: { [weak self] forecasts in
                self?.waveForecasts = forecasts
            })
            .eraseToAnyPublisher()
    }
    
    private func fetchTideData() -> AnyPublisher<[TideData], Error> {
        return noaaService.fetchTideData(stationId: selectedTideStation.id)
            .handleEvents(receiveOutput: { [weak self] tideData in
                self?.tideData = tideData
            })
            .eraseToAnyPublisher()
    }
}
