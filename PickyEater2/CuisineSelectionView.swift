import SwiftUI

struct CuisineSelectionView: View {
    @Binding var preferences: UserPreferences
    @State private var selectedCuisines: Set<String> = []
    
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
        NavigationStack {
            VStack(spacing: 24) {
                Text("Pick your food")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top)
                
                Text("Select the type of cuisine 🍽️")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                ScrollView {
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
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedCuisines.contains(cuisine) ? Color.pink : Color.white)
                                    )
                                    .foregroundColor(selectedCuisines.contains(cuisine) ? .white : .black)
                            }
                        }
                    }
                    .padding()
                }
                
                NavigationLink {
                    LocationSelectionView(preferences: $preferences)
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
                            .fill(selectedCuisines.isEmpty ? Color.gray : Color.white)
                    )
                    .foregroundColor(selectedCuisines.isEmpty ? .white : .black)
                }
                .disabled(selectedCuisines.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color.black)
            .preferredColorScheme(.dark)
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
    CuisineSelectionView(preferences: .constant(UserPreferences()))
} 