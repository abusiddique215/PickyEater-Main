import MapKit
import SwiftUI

struct RestaurantMapView: View {
    // Properties...

    var body: some View {
        VStack {
            // Your view components...
            // For example:
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.restaurants) { restaurant in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude))
            }
        }
    }
}
