import CoreLocation
import SwiftUI
import PickyEater2Core

struct LocationSelectionView: View {
    @Binding var preferences: UserPreferences
    @State private var selectedLocation: String?
    @StateObject private var locationManager = LocationManager()

    private let locations: [String: CLLocationCoordinate2D] = [
        "Current Location": CLLocationCoordinate2D(latitude: 40.68035, longitude: -73.86539),
        "Montreal": CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
        "Laurentides": CLLocationCoordinate2D(latitude: 46.0500, longitude: -74.3000),
        "Laval": CLLocationCoordinate2D(latitude: 45.6066, longitude: -73.7124),
        "West Island": CLLocationCoordinate2D(latitude: 45.4911, longitude: -73.7673),
        "South Shore": CLLocationCoordinate2D(latitude: 45.4255, longitude: -73.6337),
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("Pick your location")
                .font(.system(size: 40, weight: .bold))
                .padding(.top)

            Text("Select an area 📍")
                .font(.title2)
                .foregroundColor(.secondary)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(locations.keys.sorted(), id: \.self) { location in
                        Button {
                            selectedLocation = location
                            if let coordinate = locations[location] {
                                let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                locationManager.location = newLocation
                                locationManager.state = .authorized
                            }
                        } label: {
                            Text(location)
                                .font(.system(.body, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(selectedLocation == location ? Color.pink : Color.white)
                                )
                                .foregroundColor(selectedLocation == location ? .white : .black)
                        }
                    }
                }
                .padding()
            }

            if locationManager.location != nil {
                NavigationLink {
                    RestaurantListView(preferences: preferences)
                } label: {
                    HStack {
                        Text("NEXT")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedLocation == nil ? Color.gray : Color.white)
                    )
                    .foregroundColor(selectedLocation == nil ? .white : .black)
                }
                .disabled(selectedLocation == nil)
                .padding(.horizontal)
                .padding(.bottom)
            } else {
                ProgressView("Getting your location...")
                    .padding()
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationStack {
        LocationSelectionView(preferences: .constant(UserPreferences()))
    }
    .modelContainer(for: UserPreferences.self, inMemory: true)
}
