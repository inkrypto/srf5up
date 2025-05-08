import SwiftUI

struct WaveConditionsView: View {
    @ObservedObject var viewModel: ForecastViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Title
                Text("Wave Conditions")
                    .font(.headline)
                    .padding(.top, 4)
                
                if let buoyData = viewModel.currentBuoyData {
                    // Wave metrics grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        // Wave Height
                        MetricView(
                            title: "Height",
                            value: buoyData.heightShort,
                            systemImage: "water.waves",
                            accentColor: .blue)
                        
                        // Wave Period
                        MetricView(
                            title: "Period",
                            value: buoyData.periodShort,
                            systemImage: "clock",
                            accentColor: .green)
                        
                        // Direction
                        if buoyData.waveDirection != "N/A" && buoyData.waveDirection != "MM" {
                            let directionDegrees = Double(buoyData.waveDirection) ?? 0
                            let direction = DirectionHelper.degreesToCardinal(degrees: directionDegrees)
                            
                            MetricView(
                                title: "Direction",
                                value: direction,
                                systemImage: "location.north.fill",
                                accentColor: .orange)
                        }
                        
                        // Water temperature if available
                        if let temp = buoyData.waterTemperature, temp != "N/A" && temp != "MM" {
                            MetricView(
                                title: "Water",
                                value: "\(temp)°C",
                                systemImage: "thermometer",
                                accentColor: .teal)
                        }
                    }
                    
                    // Last updated
                    Text("Updated: \(formatTime(buoyData.time))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                } else {
                    Text("No wave data available")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                // Refresh Button
                Button(action: {
                    viewModel.loadData()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.caption2)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .padding(.top, 4)
                
                // Buoy name
                Text(viewModel.selectedBuoy.name)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
    }
    
    // Format time to be more readable
    private func formatTime(_ timeString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        
        if let date = dateFormatter.date(from: timeString) {
            return outputFormatter.string(from: date)
        }
        
        return timeString
    }
}

struct MetricView: View {
    let title: String
    let value: String
    let systemImage: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 16))
                .foregroundColor(accentColor)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(accentColor.opacity(0.1))
        )
    }
}

#Preview {
    // Creating sample data for preview
    let viewModel = ForecastViewModel()
    
    // Sample buoy data
    viewModel.currentBuoyData = BuoyData(
        time: "2025-05-08 13:00",
        waveHeight: "1.8",
        waveDirection: "280",
        wavePeriod: "12",
        windSpeed: "15",
        windDirection: "270",
        waterTemperature: "14.5"
    )
    
    return WaveConditionsView(viewModel: viewModel)
        .previewDevice("Apple Watch Series 7 - 45mm")
}
