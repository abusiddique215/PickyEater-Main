import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    @StateObject private var viewModel: RestaurantDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(restaurant: Restaurant, yelpService: YelpAPIService) {
        _viewModel = StateObject(wrappedValue: RestaurantDetailViewModel(restaurant: restaurant, yelpService: yelpService))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Image
                AsyncImage(url: URL(string: viewModel.restaurant.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipped()
                
                // Restaurant Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(viewModel.restaurant.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { viewModel.toggleFavorite() }) {
                            Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(viewModel.isFavorite ? .red : .gray)
                        }
                    }
                    
                    // Rating and Price
                    HStack {
                        RatingView(rating: viewModel.restaurant.rating)
                        Text("(\(viewModel.restaurant.reviewCount) reviews)")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(repeating: "$", count: viewModel.restaurant.priceRange.rawValue))
                            .foregroundColor(.green)
                    }
                    
                    // Categories
                    FlowLayout(spacing: 8) {
                        ForEach(viewModel.restaurant.categories, id: \.self) { category in
                            Text(category)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    
                    // Address and Map
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.headline)
                        
                        Text(viewModel.restaurant.address)
                            .foregroundColor(.secondary)
                        
                        Map(coordinateRegion: $viewModel.region, annotationItems: [viewModel.restaurant]) { restaurant in
                            MapMarker(coordinate: CLLocationCoordinate2D(
                                latitude: restaurant.coordinates.latitude,
                                longitude: restaurant.coordinates.longitude
                            ))
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                        
                        Button(action: { viewModel.getDirections() }) {
                            Label("Get Directions", systemImage: "location.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    // Reviews
                    if !viewModel.reviews.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reviews")
                                .font(.headline)
                            
                            ForEach(viewModel.reviews) { review in
                                ReviewCard(review: review)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.share() }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
}

struct RatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(rating) ? "star.fill" :
                        (rating - Double(index) >= 0.5 ? "star.leadinghalf.filled" : "star"))
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.userName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                RatingView(rating: review.rating)
            }
            
            Text(review.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(review.timeCreated.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.tertiary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, line) in result.lines.enumerated() {
            let y = result.lineY[index]
            var x = bounds.minX
            
            for item in line {
                let position = CGPoint(x: x, y: y)
                subviews[item.index].place(at: position, proposal: ProposedViewSize(item.size))
                x += item.size.width + spacing
            }
        }
    }
    
    struct FlowResult {
        var lines: [[Item]] = [[]]
        var lineY: [CGFloat] = [0]
        var size: CGSize = .zero
        
        struct Item {
            let index: Int
            let size: CGSize
        }
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            var lineIndex = 0
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > width, !lines[lineIndex].isEmpty {
                    // Start new line
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                    lineIndex += 1
                    lines.append([])
                    lineY.append(y)
                }
                
                lines[lineIndex].append(Item(index: index, size: size))
                x += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            size = CGSize(width: width, height: y + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(
            restaurant: Restaurant(
                id: "1",
                name: "Sample Restaurant",
                cuisineType: "Italian",
                rating: 4.5,
                priceLevel: "$$$",
                imageURL: nil
            ),
            yelpService: YelpAPIService()
        )
    }
}
