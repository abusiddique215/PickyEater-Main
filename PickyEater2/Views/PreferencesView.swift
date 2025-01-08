import LocalAuthentication
import SwiftData
import SwiftUI

struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var preferences: UserPreferences
    @State private var selectedRestrictions: Set<String> = []
    @State private var isAuthenticated = false

    // Modern color scheme (matching our other views)
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25), // DoorDash red
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97), // Light gray
        text: Color.white,
        cardBackground: Color(white: 0.12) // Slightly lighter than black
    )

    private let dietaryOptions = [
        "Vegetarian",
        "Vegan",
        "Gluten-Free",
        "Halal",
        "Kosher",
        "Dairy-Free",
    ]

    var body: some View {
        Group {
            if isAuthenticated {
                preferencesContent
            } else {
                AuthenticationView(isAuthenticated: $isAuthenticated)
            }
        }
    }

    private var preferencesContent: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Dietary Restrictions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("DIETARY RESTRICTIONS")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(colors.secondary)
                            .padding(.horizontal)

                        VStack(spacing: 2) {
                            ForEach(dietaryOptions, id: \.self) { option in
                                DietaryToggleRowModern(
                                    option: option,
                                    isSelected: selectedRestrictions.contains(option),
                                    onToggle: { isSelected in
                                        if isSelected {
                                            selectedRestrictions.insert(option)
                                        } else {
                                            selectedRestrictions.remove(option)
                                        }
                                        preferences.dietaryRestrictions = Array(selectedRestrictions)
                                    },
                                    colors: colors
                                )

                                if option != dietaryOptions.last {
                                    Divider()
                                        .background(Color(white: 0.2))
                                }
                            }
                        }
                        .background(colors.cardBackground)
                        .cornerRadius(16)
                    }

                    // Price Range Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PRICE RANGE")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(colors.secondary)
                            .padding(.horizontal)

                        HStack(spacing: 12) {
                            ForEach(1 ... 4, id: \.self) { price in
                                Button {
                                    preferences.priceRange = price
                                } label: {
                                    Text(String(repeating: "$", count: price))
                                        .font(.headline)
                                        .foregroundColor(preferences.priceRange == price ? colors.primary : colors.text)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(
                                            preferences.priceRange == price ?
                                                colors.cardBackground : Color(white: 0.08)
                                        )
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    preferences.priceRange == price ?
                                                        colors.primary : Color.clear,
                                                    lineWidth: 1
                                                )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Distance Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MAXIMUM DISTANCE")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(colors.secondary)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            HStack {
                                Text("\(preferences.maxDistance) km")
                                    .font(.headline)
                                    .foregroundColor(colors.text)
                                Spacer()
                            }

                            Slider(
                                value: .init(
                                    get: { Double(preferences.maxDistance) },
                                    set: { preferences.maxDistance = Int($0) }
                                ),
                                in: 1 ... 20,
                                step: 1
                            )
                            .tint(colors.primary)

                            HStack {
                                Text("1 km")
                                Spacer()
                                Text("20 km")
                            }
                            .font(.caption)
                            .foregroundColor(colors.secondary)
                        }
                        .padding()
                        .background(colors.cardBackground)
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .background(colors.background.ignoresSafeArea())
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(colors.primary)
                }
            }
            .onAppear {
                selectedRestrictions = Set(preferences.dietaryRestrictions)
            }
        }
    }
}

struct DietaryToggleRowModern: View {
    let option: String
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    let colors: (
        background: Color,
        primary: Color,
        secondary: Color,
        text: Color,
        cardBackground: Color
    )

    var body: some View {
        Toggle(isOn: Binding(
            get: { isSelected },
            set: onToggle
        )) {
            Text(option)
                .foregroundColor(colors.text)
        }
        .tint(colors.primary)
        .padding()
    }
}

#Preview {
    PreferencesView(preferences: .constant(UserPreferences()))
        .modelContainer(for: UserPreferences.self, inMemory: true)
        .preferredColorScheme(.dark)
}
