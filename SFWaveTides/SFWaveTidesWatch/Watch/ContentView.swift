import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ForecastViewModel()
    
    var body: some View {
        TabView {
            // Main tide info page
            TideView(viewModel: viewModel)
            
            // Wave conditions page
            WaveConditionsView(viewModel: viewModel)
            
            // Buoy selection page
            BuoySelectionView(viewModel: viewModel)
        }
        .tabViewStyle(.page)
        .onAppear {
            viewModel.loadData()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    ContentView()
}
