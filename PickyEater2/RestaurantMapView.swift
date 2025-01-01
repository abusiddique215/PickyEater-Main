import SwiftUI
import MapKit

struct RestaurantMapView: View {
    let restaurants: [Restaurant]
    @State private var selectedRestaurant: Restaurant?
    @State private var camera: MapCameraPosition
    @State private var lookAroundScene: MKLookAroundScene?
    @Environment(\.appTheme) private var theme
    
    init(restaurants: [Restaurant], centerCoordinate: CLLocationCoordinate2D) {
        self.restaurants = restaurants
        _camera = State(initialValue: .region(MKCoordinateRegion(
            center: centerCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )))
    }
    
    var body: some View {
        Map(position: $camera) {
            ForEach(restaurants) { restaurant in
                let coordinate = CLLocationCoordinate2D(
                    latitude: restaurant.location.latitude,
                    longitude: restaurant.location.longitude
                )
                Marker(restaurant.name, coordinate: coordinate)
                    .tint(selectedRestaurant?.id == restaurant.id ? .pink : .blue)
            }
        }
        .mapStyle(theme == .dark ? 
            .standard(elevation: .realistic, pointsOfInterest: .all, showsTraffic: true)
            : .standard(elevation: .realistic))
        .overlay(alignment: .bottom) {
            if let selectedRestaurant {
                RestaurantPreviewCard(restaurant: selectedRestaurant) {
                    withAnimation {
                        self.selectedRestaurant = nil
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
        .safeAreaInset(edge: .bottom) {
            if lookAroundScene != nil {
                LookAroundPreview(scene: $lookAroundScene)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
        }
        .onChange(of: selectedRestaurant) { _, restaurant in
            guard let restaurant else { return }
            // Update map camera to focus on selected restaurant
            withAnimation {
                camera = .region(MKCoordinateRegion(
                    center: .init(
                        latitude: restaurant.location.latitude,
                        longitude: restaurant.location.longitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            }
            // Try to load Look Around scene
            Task {
                lookAroundScene = try? await loadLookAroundScene(for: restaurant)
            }
        }
    }
    
    private func loadLookAroundScene(for restaurant: Restaurant) async throws -> MKLookAroundScene? {
        let coordinate = CLLocationCoordinate2D(
            latitude: restaurant.location.latitude,
            longitude: restaurant.location.longitude
        )
        return try? await MKLookAroundSceneRequest(coordinate: coordinate).scene
    }
}

struct RestaurantPreviewCard: View {
    let restaurant: Restaurant
    let onDismiss: () -> Void
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(restaurant.name)
                    .font(.headline)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            if let firstPhoto = restaurant.photos.first,
               let url = URL(string: firstPhoto) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            HStack {
                Label(restaurant.location.address1, systemImage: "location.fill")
                    .foregroundStyle(.secondary)
                Spacer()
                if let price = restaurant.price {
                    Text(price)
                        .foregroundStyle(.green)
                }
            }
            
            HStack {
                ForEach(restaurant.categories, id: \.alias) { category in
                    Text(category.title)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            
            HStack {
                if restaurant.rating > 0 {
                    Label(String(format: "%.1f", restaurant.rating), systemImage: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("(\(restaurant.reviewCount) reviews)")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let phone = restaurant.displayPhone {
                    Button {
                        guard let url = URL(string: "tel:\(phone)") else { return }
                        UIApplication.shared.open(url)
                    } label: {
                        Label(phone, systemImage: "phone.fill")
                    }
                }
            }
            
            Button {
                let query = "\(restaurant.location.address1), \(restaurant.location.city)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "maps://?q=\(query)") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Get Directions")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(theme == .dark ? .black : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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