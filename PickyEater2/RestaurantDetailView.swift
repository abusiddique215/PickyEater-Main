import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingReminderOptions = false
    @State private var showingNotificationError = false
    
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),
        text: Color.white,
        cardBackground: Color(white: 0.12)
    )
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Restaurant Image
                AsyncImage(url: URL(string: restaurant.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay {
                                ProgressView()
                                    .tint(colors.primary)
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(colors.secondary)
                            }
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(height: 200)
                .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Restaurant Name and Rating
                    HStack {
                        Text(restaurant.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colors.text)
                        
                        Spacer()
                        
                        Button {
                            showingReminderOptions = true
                        } label: {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundColor(colors.primary)
                        }
                    }
                    
                    // Rating and Reviews
                    HStack {
                        ForEach(0..<Int(restaurant.rating), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        Text("(\(restaurant.reviewCount) reviews)")
                            .foregroundColor(colors.secondary)
                    }
                    
                    // Categories
                    if !restaurant.categories.isEmpty {
                        HStack {
                            ForEach(restaurant.categories, id: \.alias) { category in
                                Text(category.title)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(colors.cardBackground)
                                    .foregroundColor(colors.text)
                                    .cornerRadius(15)
                            }
                        }
                    }
                    
                    // Price and Distance
                    HStack {
                        if let price = restaurant.price {
                            Text(price)
                                .foregroundColor(.green)
                        }
                        if let distance = restaurant.distance {
                            Text("•")
                                .foregroundColor(colors.secondary)
                            Text(String(format: "%.1f km", distance / 1000))
                                .foregroundColor(colors.secondary)
                        }
                    }
                    
                    // Address
                    VStack(alignment: .leading) {
                        Text("Location")
                            .font(.headline)
                            .foregroundColor(colors.text)
                        Text("\(restaurant.location.address1)")
                            .foregroundColor(colors.secondary)
                        Text("\(restaurant.location.city), \(restaurant.location.state)")
                            .foregroundColor(colors.secondary)
                    }
                    
                    // Action Buttons
                    HStack {
                        ActionButton(
                            title: "Get Directions",
                            icon: "location.fill",
                            action: openInMaps
                        )
                        
                        if !restaurant.phone.isEmpty {
                            ActionButton(
                                title: "Call",
                                icon: "phone.fill",
                                action: callRestaurant
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .background(colors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Set Reminder",
            isPresented: $showingReminderOptions,
            titleVisibility: .visible
        ) {
            Button("Remind in 1 hour") {
                scheduleReminder(hours: 1)
            }
            Button("Remind in 4 hours") {
                scheduleReminder(hours: 4)
            }
            Button("Remind tomorrow") {
                scheduleReminder(hours: 24)
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Notification Error", isPresented: $showingNotificationError) {
            Button("OK", role: .cancel) {}
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable notifications in settings to set reminders.")
        }
    }
    
    private func scheduleReminder(hours: Double) {
        if notificationManager.hasPermission {
            notificationManager.scheduleRestaurantReminder(
                restaurant: restaurant,
                timeInterval: hours * 3600
            )
        } else {
            showingNotificationError = true
        }
    }
    
    private func openInMaps() {
        let query = "\(restaurant.location.address1), \(restaurant.location.city)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(query)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func callRestaurant() {
        if let url = URL(string: "tel:\(restaurant.phone)") {
            UIApplication.shared.open(url)
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(red: 0.98, green: 0.24, blue: 0.25))
            .cornerRadius(12)
        }
    }
} 