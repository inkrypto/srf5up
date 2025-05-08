import SwiftUI

struct CurrentTideView: View {
    @ObservedObject var viewModel: ForecastViewModel
    
    var currentTide: TideData? {
        getCurrentTide()
    }
    
    var nextTide: TideData? {
        getNextTide()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Tide Information")
                .font(.headline)
                .padding(.top)
            
            if let current = currentTide, let next = nextTide {
                HStack(spacing: 0) {
                    // Current Tide Card
                    VStack {
                        Text("Current Tide")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(current.type == "H" ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(current.type == "H" ? Color.red : Color.blue, lineWidth: 1)
                                )
                            
                            VStack(spacing: 12) {
                                Image(systemName: current.type == "H" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(current.type == "H" ? .red : .blue)
                                
                                Text(current.typeFormatted)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(current.type == "H" ? .red : .blue)
                                
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    Text(current.height)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text("ft")
                                        .font(.caption)
                                        .padding(.bottom, 2)
                                }
                                
                                Text(formatTideTime(current.time))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // Direction arrow
                    VStack {
                        Image(systemName: "arrow.right")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    
                    // Next Tide Card
                    VStack {
                        Text("Next Tide")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(next.type == "H" ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(next.type == "H" ? Color.red : Color.blue, lineWidth: 1)
                                )
                            
                            VStack(spacing: 12) {
                                Image(systemName: next.type == "H" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(next.type == "H" ? .red : .blue)
                                
                                Text(next.typeFormatted)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(next.type == "H" ? .red : .blue)
                                
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    Text(next.height)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text("ft")
                                        .font(.caption)
                                        .padding(.bottom, 2)
                                }
                                
                                Text(formatTideTime(next.time))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding()
                
                // Time until next tide
                if let timeRemaining = getTimeUntilNextTide(next) {
                    Text("Time until next tide: \(timeRemaining)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            } else {
                ContentUnavailableView(
                    "No Tide Data",
                    systemImage: "water.waves",
                    description: Text("Pull to refresh or try again later")
                )
                .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
        )
        .padding()
    }
    
    // Find the current tide based on time
    private func getCurrentTide() -> TideData? {
        guard !viewModel.tideData.isEmpty else { return nil }
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // Find the previous tide that has already occurred
        var currentTide: TideData? = nil
        
        for tide in viewModel.tideData {
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
        guard !viewModel.tideData.isEmpty else { return nil }
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // Find the next tide that hasn't occurred yet
        var nextTide: TideData? = nil
        
        for tide in viewModel.tideData {
            if let tideDate = dateFormatter.date(from: tide.time), tideDate > now {
                // If this is the first future tide we've found or it's earlier than our current next one
                if nextTide == nil || dateFormatter.date(from: nextTide!.time)! > tideDate {
                    nextTide = tide
                }
            }
        }
        
        return nextTide
    }
    
    // Format tide time to be more readable
    private func formatTideTime(_ timeString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        
        if let date = dateFormatter.date(from: timeString) {
            return outputFormatter.string(from: date)
        }
        
        return timeString
    }
    
    // Calculate time remaining until next tide
    private func getTimeUntilNextTide(_ nextTide: TideData) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let tideDate = dateFormatter.date(from: nextTide.time) else {
            return nil
        }
        
        let now = Date()
        let timeInterval = tideDate.timeIntervalSince(now)
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) minutes"
        }
    }
}

#Preview {
    // Creating sample tide data for preview
    let viewModel = ForecastViewModel()
    
    // Manually adding sample tide data for preview
    let calendar = Calendar.current
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    // Current tide (2 hours ago)
    let currentTideTime = calendar.date(byAdding: .hour, value: -2, to: now)!
    let currentTideString = dateFormatter.string(from: currentTideTime)
    
    // Next tide (3 hours from now)
    let nextTideTime = calendar.date(byAdding: .hour, value: 3, to: now)!
    let nextTideString = dateFormatter.string(from: nextTideTime)
    
    // Sample data
    viewModel.tideData = [
        TideData(id: UUID(), time: currentTideString, height: "2.4", type: "L"),
        TideData(id: UUID(), time: nextTideString, height: "5.8", type: "H")
    ]
    
    return CurrentTideView(viewModel: viewModel)
        .previewLayout(.sizeThatFits)
}
