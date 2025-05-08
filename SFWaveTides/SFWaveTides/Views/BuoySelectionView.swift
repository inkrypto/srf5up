import SwiftUI
import MapKit

struct BuoySelectionView: View {
    @ObservedObject var viewModel: ForecastViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    )
    
    var body: some View {
        NavigationView {
            VStack {
                Map {
                    ForEach(Buoy.sfBuoys) { buoy in
                        Marker(buoy.name, coordinate: CLLocationCoordinate2D(
                            latitude: buoy.latitude, 
                            longitude: buoy.longitude
                        ))
                        .tint(buoy.id == viewModel.selectedBuoy.id ? .red : .blue)
                    }
                }
                .mapStyle(.standard)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                
                List {
                    ForEach(Buoy.sfBuoys) { buoy in
                        Button(action: {
                            withAnimation {
                                viewModel.selectBuoy(buoy)
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(buoy.name + " Buoy")
                                        .font(.headline)
                                    
                                    Text("ID: \(buoy.id)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if buoy.id == viewModel.selectedBuoy.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Select Buoy")
        }
    }
}

#Preview {
    BuoySelectionView(viewModel: ForecastViewModel())
}
