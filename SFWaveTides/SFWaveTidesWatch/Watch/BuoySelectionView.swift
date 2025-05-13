import SwiftUI

struct BuoySelectionView: View {
    @ObservedObject var viewModel: ForecastViewModel
    @State private var isDefaultSelectionHighlighted = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Title
                Text("Buoy Selection")
                    .font(.headline)
                    .padding(.top, 4)
                
                // Default buoy highlighted section
                if viewModel.selectedBuoy.id == "46237" {
                    VStack(spacing: 6) {
                        Text("Using default station")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            
                            Text("46237 - San Francisco Bar")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.2))
                        )
                    }
                }
                
                // Divider with label
                HStack {
                    VStack { Divider() }
                    Text("Select Buoy")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    VStack { Divider() }
                }
                .padding(.vertical, 4)
                
                // Buoy List
                ForEach(Buoy.sfBuoys) { buoy in
                    Button(action: {
                        withAnimation {
                            viewModel.selectBuoy(buoy)
                        }
                    }) {
                        HStack {
                            Text("\(buoy.id) - \(buoy.name)")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(buoy.id == viewModel.selectedBuoy.id ? .semibold : .regular)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            
                            if buoy.id == viewModel.selectedBuoy.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(buoy.id == viewModel.selectedBuoy.id ? 
                                      Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Reset to default button
                if viewModel.selectedBuoy.id != "46237" {
                    Button(action: {
                        withAnimation {
                            viewModel.selectBuoy(Buoy.defaultBuoy)
                        }
                    }) {
                        Label("Reset to Default (46237)", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            // Briefly highlight the default selection if that's what's selected
            if viewModel.selectedBuoy.id == "46237" {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isDefaultSelectionHighlighted = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isDefaultSelectionHighlighted = false
                    }
                }
            }
        }
    }
}

#Preview {
    BuoySelectionView(viewModel: ForecastViewModel())
        .previewDevice("Apple Watch Series 7 - 45mm")
}
