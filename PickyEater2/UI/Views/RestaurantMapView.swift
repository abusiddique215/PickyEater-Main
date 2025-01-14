import MapKit
import PickyEater2Core
import SwiftUI

struct RestaurantMapView: View {
    let restaurants: [AppRestaurant]
    let centerCoordinate: CLLocationCoordinate2D
    @State private var selectedRestaurant: AppRestaurant?
    @State private var region: MKCoordinateRegion

    init(restaurants: [AppRestaurant], centerCoordinate: CLLocationCoordinate2D) {
        self.restaurants = restaurants
        self.centerCoordinate = centerCoordinate
        _region = State(initialValue: MKCoordinateRegion(
            center: centerCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }

    var body: some View {
        Map(coordinateRegion: .constant(region)) {
            ForEach(restaurants) { restaurant in
                let coordinate = CLLocationCoordinate2D(
                    latitude: restaurant.coordinates.latitude,
                    longitude: restaurant.coordinates.longitude
                )

                Marker(restaurant.name, coordinate: coordinate)
                    .tint(.red)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct RestaurantCallout: View {
    let restaurant: AppRestaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(restaurant.name)
                .font(.headline)

            if let categories = restaurant.categories.first {
                Text(categories.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text(String(format: "%.1f mi", restaurant.distance))
                Text("•")
                Text(restaurant.priceRange.description)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(8)
        .background(.background)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    let sampleRestaurant = AppRestaurant(
        id: "1",
        name: "Sample Restaurant",
        distance: 1.5,
        priceRange: .twoDollars,
        categories: [Category(alias: "italian", title: "Italian")],
        imageUrl: "",
        coordinates: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        location: AppLocation(address1: "123 Main St", city: "San Francisco", state: "CA", zipCode: "94105")
    )

    NavigationStack {
        RestaurantMapView(
            restaurants: [sampleRestaurant],
            centerCoordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        )
    }
}
