import SwiftUI

struct TideStationSelectionView: View {
    @ObservedObject var viewModel: ForecastViewModel
    @State private var showingAddStationSheet = false
    @State private var searchText = ""
    
    var filteredPredefinedStations: [TideStation] {
        if searchText.isEmpty {
            return TideStation.predefinedStations
        } else {
            return TideStation.predefinedStations.filter { 
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.id.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var filteredCustomStations: [TideStation] {
        if searchText.isEmpty {
            return viewModel.customTideStations
        } else {
            return viewModel.customTideStations.filter { 
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.id.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current Station")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(viewModel.selectedTideStation.name)
                                .font(.headline)
                            
                            Text("ID: \(viewModel.selectedTideStation.id)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                if !filteredCustomStations.isEmpty {
                    Section(header: Text("Custom Stations")) {
                        ForEach(filteredCustomStations) { station in
                            stationRow(station)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.removeCustomTideStation(station)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                
                Section(header: Text("NOAA Predefined Stations")) {
                    ForEach(filteredPredefinedStations) { station in
                        stationRow(station)
                    }
                }
                
                Section {
                    Button(action: {
                        showingAddStationSheet = true
                    }) {
                        Label("Add Custom Station", systemImage: "plus.circle")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search by name or ID")
            .navigationTitle("Tide Stations")
            .sheet(isPresented: $showingAddStationSheet) {
                AddStationView(viewModel: viewModel, isPresented: $showingAddStationSheet)
            }
        }
    }
    
    private func stationRow(_ station: TideStation) -> some View {
        Button(action: {
            viewModel.selectTideStation(station)
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(station.name)
                        .font(.subheadline)
                    
                    Text("ID: \(station.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if station.id == viewModel.selectedTideStation.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct AddStationView: View {
    @ObservedObject var viewModel: ForecastViewModel
    @Binding var isPresented: Bool
    @State private var stationId: String = ""
    @State private var stationName: String = ""
    @FocusState private var idFieldIsFocused: Bool
    @State private var showingHelp = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Station Information")) {
                    TextField("NOAA Station ID (required)", text: $stationId)
                        .keyboardType(.numbersAndPunctuation)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($idFieldIsFocused)
                    
                    TextField("Station Name (optional)", text: $stationName)
                    
                    Button(action: {
                        showingHelp = true
                    }) {
                        Label("How to find station IDs", systemImage: "questionmark.circle")
                    }
                }
                
                Section(footer: Text("You can find station IDs on the NOAA Tides & Currents website.")) {
                    Button("Add Station") {
                        viewModel.addCustomTideStation(id: stationId, name: stationName)
                        isPresented = false
                    }
                    .disabled(stationId.isEmpty)
                    .frame(maxWidth: .infinity)
                }
                
                Section {
                    Button("Cancel", role: .cancel) {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Add Tide Station")
            .onAppear {
                idFieldIsFocused = true
            }
            .sheet(isPresented: $showingHelp) {
                StationIDHelpView()
            }
        }
    }
}

struct StationIDHelpView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Find NOAA Station IDs")
                        .font(.headline)
                    
                    Text("To find a tide station ID, follow these steps:")
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HelpStep(number: 1, text: "Visit the NOAA Tides & Currents website at tidesandcurrents.noaa.gov")
                        
                        HelpStep(number: 2, text: "From the map or search, find the location you're interested in")
                        
                        HelpStep(number: 3, text: "Click on a station to view its details")
                        
                        HelpStep(number: 4, text: "Look for the station ID number, usually a 7-digit number")
                        
                        HelpStep(number: 5, text: "Enter that number in this app to get tide predictions for that location")
                    }
                    
                    Divider()
                    
                    Text("Example Station IDs:")
                        .font(.headline)
                    
                    Group {
                        Text("9414290 - San Francisco, CA")
                        Text("9410230 - La Jolla, CA")
                        Text("9410170 - San Diego, CA")
                        Text("9447130 - Seattle, WA")
                        Text("8518750 - The Battery, NY")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Text("Note: Not all stations provide tide predictions.")
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    Link(destination: URL(string: "https://tidesandcurrents.noaa.gov/map/")!) {
                        HStack {
                            Text("Open NOAA Tides & Currents Website")
                            Image(systemName: "globe")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Finding Station IDs")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HelpStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(number).")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(width: 25, alignment: .leading)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    TideStationSelectionView(viewModel: ForecastViewModel())
}
