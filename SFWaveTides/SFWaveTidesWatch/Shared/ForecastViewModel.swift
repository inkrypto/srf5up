import Foundation
import Combine

class ForecastViewModel: ObservableObject {
    private let noaaService = NOAAService()
    private var cancellables = Set<AnyCancellable>()
    
    // Published properties for the UI
    @Published var currentBuoyData: BuoyData?
    @Published var tideData: [TideData] = []
    @Published var selectedBuoy: Buoy = Buoy.defaultBuoy
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var currentTide: TideData? {
        getCurrentTide()
    }
    
    var nextTide: TideData? {
        getNextTide()
    }
    
    init() {
        // Initially load data for the default buoy
        loadData()
    }
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        // Create a group for both data fetches (minimal for Watch)
        Publishers.Zip(
            fetchCurrentBuoyData(),
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
            receiveValue: { _, _ in
                // All data has been updated through individual publishers
            }
        )
        .store(in: &cancellables)
    }
    
    func selectBuoy(_ buoy: Buoy) {
        selectedBuoy = buoy
        loadData()
    }
    
    private func fetchCurrentBuoyData() -> AnyPublisher<BuoyData, Error> {
        return noaaService.fetchBuoyData(buoyId: selectedBuoy.id)
            .handleEvents(receiveOutput: { [weak self] data in
                self?.currentBuoyData = data
            })
            .eraseToAnyPublisher()
    }
    
    private func fetchTideData() -> AnyPublisher<[TideData], Error> {
        return noaaService.fetchTideData()
            .handleEvents(receiveOutput: { [weak self] tideData in
                self?.tideData = tideData
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods for Tide Data
    
    // Find the current tide based on time
    private func getCurrentTide() -> TideData? {
        guard !tideData.isEmpty else { return nil }
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // Find the previous tide that has already occurred
        var currentTide: TideData? = nil
        
        for tide in tideData {
            if let tideDate = dateFormatter.date(from: tide.time), tideDate <= now {
                // If this is the first tide we've found or it's more recent than our current one
                if currentTide == nil || dateFormatter.date(from: currentTide!.time)! < tideDate {
                    currentTide = tide
                }
            }
        }
        
        return currentTide
    }
    
    // Find the next tide based on time
    private func getNextTide() -> TideData? {
        guard !tideData.isEmpty else { return nil }
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // Find the next tide that hasn't occurred yet
        var nextTide: TideData? = nil
        
        for tide in tideData {
            if let tideDate = dateFormatter.date(from: tide.time), tideDate > now {
                // If this is the first future tide we've found or it's earlier than our current next one
                if nextTide == nil || dateFormatter.date(from: nextTide!.time)! > tideDate {
                    nextTide = tide
                }
            }
        }
        
        return nextTide
    }
    
    // Get time remaining until next tide as a string
    func getTimeUntilNextTide() -> String? {
        guard let nextTide = nextTide else { return nil }
        return DirectionHelper.getTideTimeRemaining(nextTide.time)
    }
}
