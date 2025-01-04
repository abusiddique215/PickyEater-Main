import SwiftUI

struct CuisineSelectionView: View {
    @Binding var preferences: UserPreferences
    @State private var selectedCuisines: Set<String> = []
    @State private var navigateToMainTabView = false
    @Environment(\.dismiss) private var dismiss
    
    // Modern color scheme
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),     // DoorDash red
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),   // Light gray
        text: Color.white
    )
    
    private let cuisineTypes = [
        "Afghan", "African", "Algerian", "American",
        "Argentinian", "Asian", "BBQ", "Canadian",
        "Caribbean", "Chinese", "Colombian", "Comfort Food",
        "Creole", "Filipino", "French", "Fusion", "Greek",
        "Grill", "Haitian", "Indian", "Iranian", "Irish",
        "Italian", "Japanese", "Jewish", "Korean", "Lebanese",
        "Mexican", "Middle Eastern", "Moroccan", "Persian",
        "Portuguese", "Russian", "Spanish", "Thai",
        "Ukrainian", "Vietnamese"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Previous Preferences")
                    .font(.headline)
                    .foregroundColor(colors.secondary)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(["Italian & Asian", "Mexican & Indian", "All American"], id: \.self) { preset in
                            Button {
                                // Will implement preset selection later
                            } label: {
                                Text(preset)
                                    .font(.system(.subheadline, design: .rounded))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .stroke(colors.primary, lineWidth: 1)
                                    )
                                    .foregroundColor(colors.text)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 16)
            .background(Color.black.opacity(0.8))
            
            // Main Content
            VStack(alignment: .leading, spacing: 16) {
                Text("Select cuisines")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(colors.text)
                    .padding(.horizontal)
                
                Text("Choose your favorite types of food 🍽️")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(colors.secondary)
                    .padding(.horizontal)
                
                ScrollView(showsIndicators: false) {
                    FlowLayout(spacing: 8) {
                        ForEach(cuisineTypes, id: \.self) { cuisine in
                            Button {
                                if selectedCuisines.contains(cuisine) {
                                    selectedCuisines.remove(cuisine)
                                } else {
                                    selectedCuisines.insert(cuisine)
                                }
                            } label: {
                                Text(cuisine)
                                    .font(.system(.body, design: .rounded))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(selectedCuisines.contains(cuisine) ? colors.primary : colors.secondary)
                                    )
                                    .foregroundColor(selectedCuisines.contains(cuisine) ? .white : .black)
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 80) // Extra padding for button
                }
            }
            
            // Next Button
            Button {
                preferences.cuisinePreferences = Array(selectedCuisines)
                navigateToMainTabView = true
            } label: {
                HStack(spacing: 8) {
                    Text("NEXT")
                        .fontWeight(.bold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    selectedCuisines.isEmpty ? colors.secondary.opacity(0.3) : colors.primary
                )
                .foregroundColor(selectedCuisines.isEmpty ? .gray : .white)
                .cornerRadius(16)
                .padding(.horizontal)
            }
            .disabled(selectedCuisines.isEmpty)
            .padding(.vertical)
            .background(
                Rectangle()
                    .fill(colors.background)
                    .ignoresSafeArea()
            )
        }
        .background(colors.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .navigationDestination(isPresented: $navigateToMainTabView) {
            MainTabView()
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.height }.reduce(0, +) + spacing * CGFloat(rows.count - 1)
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        
        for row in rows {
            var x = bounds.minX
            for element in row.elements {
                element.subview.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: element.width, height: element.height)
                )
                x += element.width + spacing
            }
            y += row.height + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: nil, height: nil))
            
            if x + size.width > (proposal.width ?? 0) {
                rows.append(currentRow)
                currentRow = Row()
                x = size.width + spacing
                currentRow.add(element: Element(subview: subview, size: size))
            } else {
                x += size.width + spacing
                currentRow.add(element: Element(subview: subview, size: size))
            }
        }
        
        if !currentRow.elements.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    struct Element {
        let subview: LayoutSubview
        let width: CGFloat
        let height: CGFloat
        
        init(subview: LayoutSubview, size: CGSize) {
            self.subview = subview
            self.width = size.width
            self.height = size.height
        }
    }
    
    struct Row {
        var elements: [Element] = []
        var height: CGFloat = 0
        
        mutating func add(element: Element) {
            elements.append(element)
            height = max(height, element.height)
        }
    }
}

#Preview {
    NavigationStack {
        CuisineSelectionView(preferences: .constant(UserPreferences()))
    }
} 