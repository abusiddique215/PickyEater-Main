import MapKit
import SwiftUI

struct RestaurantMapView: View {
    let restaurants: [Restaurant]
    let centerCoordinate: CLLocationCoordinate2D
    @State private var selectedRestaurant: Restaurant?

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: centerCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    var body: some View {
        Map(initialPosition: .region(region)) {
            UserAnnotation()

            ForEach(restaurants) { restaurant in
                let coordinate = CLLocationCoordinate2D(
                    latitude: restaurant.coordinates.latitude,
                    longitude: restaurant.coordinates.longitude
                )

                Marker(restaurant.name, coordinate: coordinate)
                    .tint(.red)

                if selectedRestaurant?.id == restaurant.id {
                    Annotation(restaurant.name, coordinate: coordinate) {
                        RestaurantCallout(restaurant: restaurant)
                            .onTapGesture {
                                selectedRestaurant = restaurant
                            }
                    }
                }
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
}

struct RestaurantCallout: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(restaurant.name)
                .font(.headline)

            if !restaurant.categories.isEmpty {
                Text(restaurant.categories.map(\.title).joined(separator: " • "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let price = restaurant.price {
                Text(price)
                    .font(.caption)
                    .foregroundColor(.green)
            }

            if restaurant.rating > 0 {
                HStack {
                    ForEach(0 ..< Int(restaurant.rating), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    Text("(\(restaurant.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    let sampleRestaurant = try! JSONDecoder().decode(Restaurant.self, from: """
    {
        "id": "1",
        "name": "Test Restaurant",
        "location": {
            "address1": "123 Main St",
            "city": "San Francisco",
            "state": "CA",
            "country": "US",
            "lat": 37.7749,
            "lng": -122.4194,
            "zip_code": "94105"
        },
        "categories": [
            {
                "alias": "italian",
                "title": "Italian"
            }
        ],
        "image_url": "https://example.com/image.jpg",
        "rating": 4.5,
        "review_count": 100,
        "price": "$$$",
        "display_phone": "(123) 456-7890"
    }
    """.data(using: .utf8)!)

    return RestaurantMapView(
        restaurants: [sampleRestaurant],
        centerCoordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    )
}
