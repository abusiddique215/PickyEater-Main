import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(rows.count - 1)
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
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
            width = size.width
            height = size.height
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
