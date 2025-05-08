import SwiftUI

struct TideView: View {
    @ObservedObject var viewModel: ForecastViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Title
                Text("SF Tides")
                    .font(.headline)
                    .padding(.top, 4)
                
                // Current and Next Tide Info
                if let current = viewModel.currentTide, let next = viewModel.nextTide {
                    // Current tide
                    CurrentTideCard(tide: current)
                    
                    // Divider with arrow
                    HStack {
                        Image(systemName: "arrow.down")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, -8)
                    
                    // Next tide
                    NextTideCard(tide: next, timeRemaining: viewModel.getTimeUntilNextTide())
                } else {
                    Text("No tide data available")
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
}

struct CurrentTideCard: View {
    let tide: TideData
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Current Tide")
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.bottom, 2)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(tide.typeFormatted)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(tide.type == "H" ? .red : .blue)
                    
                    Text("\(tide.height)ft")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .trailing) {
                    Text(tide.timeShort)
                        .font(.system(.subheadline, design: .rounded))
                    
                    Image(systemName: tide.type == "H" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundColor(tide.type == "H" ? .red : .blue)
                        .font(.title3)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(tide.type == "H" ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
        )
        .cornerRadius(12)
    }
}

struct NextTideCard: View {
    let tide: TideData
    let timeRemaining: String?
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Next Tide")
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.bottom, 2)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(tide.typeFormatted)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(tide.type == "H" ? .red : .blue)
                    
                    Text("\(tide.height)ft")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .trailing) {
                    if let remaining = timeRemaining {
                        Text("in \(remaining)")
                            .font(.system(.caption, design: .rounded))
                    }
                    
                    Text(tide.timeShort)
                        .font(.system(.subheadline, design: .rounded))
                    
                    Image(systemName: tide.type == "H" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundColor(tide.type == "H" ? .red : .blue)
                        .font(.title3)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(tide.type == "H" ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
        )
        .cornerRadius(12)
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
    let tides = [
        TideData(id: UUID(), time: currentTideString, height: "2.4", type: "L"),
        TideData(id: UUID(), time: nextTideString, height: "5.8", type: "H")
    ]
    
    let vm = ForecastViewModel()
    vm.tideData = tides
    
    return TideView(viewModel: vm)
        .previewDevice("Apple Watch Series 7 - 45mm")
}
