import PickyEater2Core
import SwiftUI

struct CuisineSelectionView: View {
    @EnvironmentObject var preferencesManager: PreferencesManager
    @State private var selectedCuisines: Set<String> = []
    @State private var navigateToMainTabView = false
    @Environment(\.dismiss) private var dismiss

    // Modern color scheme
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25), // DoorDash red
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97), // Light gray
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
        "Ukrainian", "Vietnamese",
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
                preferencesManager.preferences.cuisinePreferences = Array(selectedCuisines)
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

#Preview {
    CuisineSelectionView()
        .environmentObject(PreferencesManager.shared)
}
