import SwiftUI
import Core

struct PreferencesView: View {
    @EnvironmentObject var preferencesManager: PreferencesManager

    var body: some View {
        Form {
            Section(header: Text("Dietary Restrictions")) {
                ForEach(DietaryRestriction.allCases) { restriction in
                    Toggle(restriction.rawValue, isOn: Binding(
                        get: { preferencesManager.userPreferences.dietaryRestrictions.contains(restriction) },
                        set: { isOn in
                            if isOn {
                                preferencesManager.userPreferences.dietaryRestrictions.insert(restriction)
                            } else {
                                preferencesManager.userPreferences.dietaryRestrictions.remove(restriction)
                            }
                            preferencesManager.save()
                        }
                    ))
                }
            }
            // Other form sections...
        }
    }
}
