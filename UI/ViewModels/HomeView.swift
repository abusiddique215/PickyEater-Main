import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel(
        filterService: RestaurantFilterService(preferencesManager: PreferencesManager.shared)
    )

    var body: some View {
        // UI implementation...
    }
}

private struct HomeErrorView: View {
    let message: String

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(message)
                .foregroundColor(.secondary)
        }
        .padding()
    }
} 