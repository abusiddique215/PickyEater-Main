import SwiftUI

// Rename FlowLayout to CuisineFlowLayout to avoid conflicts
struct CuisineFlowLayout: Layout {
    func sizeThatFits(proposal _: ProposedViewSize, subviews _: Subviews, cache _: inout ()) -> CGSize {
        // Layout logic...
    }

    func placeSubviews(in _: CGRect, proposal _: ProposedViewSize, subviews _: Subviews, cache _: inout ()) {
        // Placement logic...
    }
}
