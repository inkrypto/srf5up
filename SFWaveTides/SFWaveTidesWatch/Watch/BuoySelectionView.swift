import SwiftUI

struct BuoySelectionView: View {
    @ObservedObject var viewModel: ForecastViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Title
                Text("Select Buoy")
                    .font(.headline)
                    .padding(.top, 4)
                
                // Buoy List
                ForEach(Buoy.sfBuoys) { buoy in
                    Button(action: {
                        viewModel.selectBuoy(buoy)
                    }) {
                        HStack {
                            Text(buoy.name)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(buoy.id == viewModel.selectedBuoy.id ? .semibold : .regular)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
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
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    BuoySelectionView(viewModel: ForecastViewModel())
        .previewDevice("Apple Watch Series 7 - 45mm")
}
