import SwiftUI

struct LocationSelectionView: View {
    @Binding var preferences: UserPreferences
    @State private var selectedLocation: String?
    @StateObject private var locationManager = LocationManager()
    
    private let locations = [
        "Montreal", "Laurentides", "Laval", "West Island", "South Shore"
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
                    ForEach(locations, id: \.self) { location in
                        Button {
                            selectedLocation = location
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
} 