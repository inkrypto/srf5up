import SwiftUI

struct CurrentConditionsView: View {
    @ObservedObject var viewModel: ForecastViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let buoyData = viewModel.currentBuoyData {
                        CurrentConditionsCard(buoyData: buoyData, buoyName: viewModel.selectedBuoy.name)
                            .padding(.horizontal)
                    } else {
                        ContentUnavailableView(
                            "No Data Available",
                            systemImage: "water.waves",
                            description: Text("Pull to refresh or try again later")
                        )
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                viewModel.loadAllData()
            }
            .navigationTitle("Current Sea Conditions")
            .toolbar {
                Button(action: {
                    viewModel.loadAllData()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

struct CurrentConditionsCard: View {
    let buoyData: BuoyData
    let buoyName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text(buoyName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Updated: \(buoyData.time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "water.waves")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            DataRow(title: "Wave Height", value: buoyData.waveHeightFormatted)
            DataRow(title: "Wave Direction", value: buoyData.waveDirectionFormatted)
            DataRow(title: "Wave Period", value: buoyData.wavePeriodFormatted)
            DataRow(title: "Wind Speed", value: buoyData.windSpeedFormatted)
            DataRow(title: "Wind Direction", value: buoyData.windDirectionFormatted)
            DataRow(title: "Water Temperature", value: buoyData.waterTemperatureFormatted)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
        )
    }
}

struct DataRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    CurrentConditionsView(viewModel: ForecastViewModel())
        .environment(\.colorScheme, .light)
}
