import SwiftUI

struct TideView: View {
    @ObservedObject var viewModel: ForecastViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.tideData.isEmpty {
                    ContentUnavailableView(
                        "No Tide Data",
                        systemImage: "arrow.up.and.down.circle",
                        description: Text("Pull to refresh or try again later")
                    )
                } else {
                    List {
                        TideChartView(tideData: viewModel.tideData)
                            .frame(height: 200)
                            .padding(.vertical)
                            .listRowSeparator(.hidden)
                        
                        ForEach(viewModel.tideData) { tide in
                            TideCard(tide: tide)
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
            .navigationTitle("Tide Schedule")
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

struct TideChartView: View {
    let tideData: [TideData]
    
    var maxHeight: Double {
        tideData.compactMap { Double($0.height) }.max() ?? 1.0
    }
    
    var body: some View {
        VStack {
            Text("Today's Tide Pattern")
                .font(.headline)
                .padding(.bottom, 8)
            
            GeometryReader { geometry in
                ZStack {
                    // Horizontal lines
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<5) { i in
                            Divider()
                                .opacity(i == 0 ? 0 : 1)
                            if i < 4 {
                                Spacer()
                            }
                        }
                    }
                    
                    // Tide visualization
                    Path { path in
                        guard !tideData.isEmpty else { return }
                        
                        let timeWidth = geometry.size.width / CGFloat(tideData.count > 1 ? tideData.count - 1 : 1)
                        let maxValue = maxHeight
                        
                        // Start at the first point
                        let firstHeight = Double(tideData[0].height) ?? 0
                        let firstY = geometry.size.height - (firstHeight / maxValue * geometry.size.height)
                        path.move(to: CGPoint(x: 0, y: firstY))
                        
                        // Add points for each tide
                        for (index, tide) in tideData.enumerated().dropFirst() {
                            let height = Double(tide.height) ?? 0
                            let x = CGFloat(index) * timeWidth
                            let y = geometry.size.height - (height / maxValue * geometry.size.height)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(Color.blue, lineWidth: 3)
                    
                    // Tide markers
                    ForEach(Array(tideData.enumerated()), id: \.element.id) { index, tide in
                        let timeWidth = geometry.size.width / CGFloat(tideData.count > 1 ? tideData.count - 1 : 1)
                        let height = Double(tide.height) ?? 0
                        let x = CGFloat(index) * timeWidth
                        let y = geometry.size.height - (height / maxValue * geometry.size.height)
                        
                        VStack {
                            Circle()
                                .fill(tide.type == "H" ? Color.red : Color.blue)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .shadow(radius: 2)
                        }
                        .position(x: x, y: y)
                    }
                }
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

struct TideCard: View {
    let tide: TideData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tide.typeFormatted + " Tide")
                    .font(.headline)
                    .foregroundColor(tide.type == "H" ? .red : .blue)
                
                Text(tide.time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(tide.height)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("ft")
                    .font(.caption)
                    .padding(.bottom, 4)
            }
            
            Image(systemName: tide.type == "H" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundColor(tide.type == "H" ? .red : .blue)
                .font(.title2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 1)
        )
    }
}

#Preview {
    TideView(viewModel: ForecastViewModel())
}
