import SwiftUI
import MapKit

struct RestaurantMapView: View {
    let restaurants: [Restaurant]
    let centerCoordinate: CLLocationCoordinate2D
    @State private var region: MKCoordinateRegion
    @State private var selectedRestaurant: Restaurant?
    
    init(restaurants: [Restaurant], centerCoordinate: CLLocationCoordinate2D) {
        self.restaurants = restaurants
        self.centerCoordinate = centerCoordinate
        // Initialize region with the center coordinate
        _region = State(initialValue: MKCoordinateRegion(
            center: centerCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: restaurants) { restaurant in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: restaurant.coordinates.latitude,
                longitude: restaurant.coordinates.longitude
            )) {
                RestaurantAnnotation(
                    restaurant: restaurant,
                    isSelected: selectedRestaurant?.id == restaurant.id
                ) {
                    selectedRestaurant = restaurant
                }
            }
        }
        .sheet(item: $selectedRestaurant) { restaurant in
            RestaurantDetailSheet(restaurant: restaurant)
                .presentationDetents([.medium])
        }
    }
}

struct RestaurantAnnotation: View {
    let restaurant: Restaurant
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(isSelected ? .red : .gray)
                
                Text(restaurant.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.7))
                    .cornerRadius(8)
            }
        }
    }
}

struct RestaurantDetailSheet: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(restaurant.name)
                .font(.title2)
                .fontWeight(.bold)
            
            if !restaurant.categories.isEmpty {
                Text(restaurant.categories.map { $0.title }.joined(separator: " • "))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", restaurant.rating))
                Text("(\(restaurant.reviewCount) reviews)")
                    .foregroundColor(.secondary)
            }
            
            if let price = restaurant.price {
                Text(price)
                    .foregroundColor(.green)
            }
            
            Text(restaurant.location.displayAddress.joined(separator: "\n"))
                .foregroundColor(.secondary)
            
            if !restaurant.phone.isEmpty {
                Button {
                    if let url = URL(string: "tel:\(restaurant.phone)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Call Restaurant", systemImage: "phone.fill")
                }
                .buttonStyle(.bordered)
            }
            
            Button {
                let query = restaurant.location.displayAddress.joined(separator: " ").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "maps://?q=\(query)") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Get Directions", systemImage: "location.fill")
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding()
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