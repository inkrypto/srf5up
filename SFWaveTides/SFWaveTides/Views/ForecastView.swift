import SwiftUI

struct ForecastView: View {
    @ObservedObject var viewModel: ForecastViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.waveForecasts.isEmpty {
                    ContentUnavailableView(
                        "No Forecast Data",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Pull to refresh or try again later")
                    )
                } else {
                    List {
                        ForEach(viewModel.waveForecasts) { forecast in
                            ForecastCard(forecast: forecast)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .refreshable {
                viewModel.loadAllData()
            }
            .navigationTitle("Wave Forecast")
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

struct ForecastCard: View {
    let forecast: BuoyData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(forecast.time)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            DataRow(title: "Wave Height", value: forecast.waveHeightFormatted)
            DataRow(title: "Wave Direction", value: forecast.waveDirectionFormatted)
            DataRow(title: "Wave Period", value: forecast.wavePeriodFormatted)
            
            if forecast.windSpeed != "N/A" {
                DataRow(title: "Wind Speed", value: forecast.windSpeedFormatted)
                DataRow(title: "Wind Direction", value: forecast.windDirectionFormatted)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    ForecastView(viewModel: ForecastViewModel())
}
