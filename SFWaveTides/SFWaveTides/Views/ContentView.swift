import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ForecastViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            CurrentConditionsView(viewModel: viewModel)
                .tabItem {
                    Label("Current", systemImage: "water.waves")
                }
            
            ForecastView(viewModel: viewModel)
                .tabItem {
                    Label("Forecast", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            TideView(viewModel: viewModel)
                .tabItem {
                    Label("Tides", systemImage: "arrow.up.and.down.circle")
                }
            
            BuoySelectionView(viewModel: viewModel)
                .tabItem {
                    Label("Buoys", systemImage: "mappin.circle")
                }
                
            TideStationSelectionView(viewModel: viewModel)
                .tabItem {
                    Label("Stations", systemImage: "building.fill")
                }
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Loading data...")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage = nil
                }
            )
        }
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: ForecastViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Current Tide Section
                    CurrentTideView(viewModel: viewModel)
                    
                    // Current Conditions Summary
                    if let buoyData = viewModel.currentBuoyData {
                        VStack(alignment: .leading) {
                            Text("Current Wave Conditions")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                // Wave Height
                                ConditionCard(
                                    title: "Wave Height",
                                    value: buoyData.waveHeightFormatted,
                                    systemImage: "water.waves")
                                
                                // Wave Period
                                ConditionCard(
                                    title: "Wave Period",
                                    value: buoyData.wavePeriodFormatted,
                                    systemImage: "clock")
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Buoy Info
                    HStack {
                        Text("Current Buoy: \(viewModel.selectedBuoy.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.loadAllData()
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                                .font(.subheadline)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("SF Wave Tides")
        }
    }
}

struct ConditionCard: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .padding(.bottom, 4)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 1)
        )
    }
}

#Preview {
    ContentView()
}
