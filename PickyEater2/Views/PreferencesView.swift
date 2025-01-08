import SwiftUI

struct PreferencesView: View {
    @StateObject private var viewModel = PreferencesViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingValidationAlert = false

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Dietary Restrictions

                Section(header: Text("Dietary Restrictions")) {
                    ForEach(DietaryRestriction.allCases, id: \.self) { restriction in
                        Toggle(restriction.description, isOn: Binding(
                            get: { viewModel.isDietaryRestrictionEnabled(restriction) },
                            set: { _ in viewModel.toggleDietaryRestriction(restriction) }
                        ))
                    }
                }

                // MARK: - Cuisine Preferences

                Section(
                    header: Text("Cuisine Preferences"),
                    footer: Text("Select at least one cuisine type")
                ) {
                    ForEach(viewModel.availableCuisines, id: \.self) { cuisine in
                        Toggle(cuisine, isOn: Binding(
                            get: { viewModel.isCuisineSelected(cuisine) },
                            set: { _ in viewModel.toggleCuisinePreference(cuisine) }
                        ))
                    }
                }

                // MARK: - Price Range

                Section(header: Text("Price Range")) {
                    Picker("Maximum Price", selection: Binding(
                        get: { viewModel.priceRange ?? .medium },
                        set: { viewModel.priceRange = $0 }
                    )) {
                        ForEach(PriceRange.allCases, id: \.self) { range in
                            Text(range.description)
                                .tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Rating

                Section(header: Text("Minimum Rating")) {
                    Picker("Minimum Rating", selection: Binding(
                        get: { viewModel.minimumRating ?? 0 },
                        set: { viewModel.minimumRating = $0 }
                    )) {
                        Text("Any").tag(0.0)
                        ForEach([3.0, 3.5, 4.0, 4.5], id: \.self) { rating in
                            Text(String(format: "%.1f★", rating)).tag(rating)
                        }
                    }
                }

                // MARK: - Distance

                Section(header: Text("Maximum Distance")) {
                    Picker("Maximum Distance", selection: Binding(
                        get: { viewModel.maximumDistance ?? 5000 },
                        set: { viewModel.maximumDistance = $0 }
                    )) {
                        Text("1 km").tag(1000.0)
                        Text("2 km").tag(2000.0)
                        Text("5 km").tag(5000.0)
                        Text("10 km").tag(10000.0)
                        Text("20 km").tag(20000.0)
                    }
                }

                // MARK: - Sort Options

                Section(header: Text("Sort Results By")) {
                    Picker("Sort By", selection: $viewModel.sortBy) {
                        Text("Best Match").tag(UserPreferences.SortOption.bestMatch)
                        Text("Rating").tag(UserPreferences.SortOption.rating)
                        Text("Review Count").tag(UserPreferences.SortOption.reviewCount)
                        Text("Distance").tag(UserPreferences.SortOption.distance)
                    }
                }

                // MARK: - Reset Button

                Section {
                    Button(role: .destructive, action: viewModel.resetAllPreferences) {
                        Text("Reset All Preferences")
                    }
                }
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if viewModel.validatePreferences() {
                            dismiss()
                        } else {
                            showingValidationAlert = true
                        }
                    }
                }
            }
            .alert("Invalid Preferences", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please select at least one cuisine type and ensure all values are valid.")
            }
        }
    }
}

#Preview {
    PreferencesView()
}
