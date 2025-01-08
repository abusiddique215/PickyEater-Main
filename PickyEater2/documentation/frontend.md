
## Documentation/frontend.md

# Frontend Documentation for PickyEater

[**View this document as part of the PickyEater project documentation.**](#)

---

**Table of Contents**

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Design Principles](#design-principles)
- [Architecture](#architecture)
- [UI Components](#ui-components)
- [Navigation Structure](#navigation-structure)
- [State Management](#state-management)
- [Styling and Theming](#styling-and-theming)
- [Forms and User Input](#forms-and-user-input)
- [Accessibility Features](#accessibility-features)
- [Error Handling in UI](#error-handling-in-ui)
- [Performance Optimization](#performance-optimization)
- [Testing](#testing)
- [Conclusion](#conclusion)

---

## Overview

The frontend of **PickyEater** is an iOS application built using **SwiftUI**, designed to provide a clean, responsive, and engaging user experience. It adheres to modern iOS design principles and supports accessibility features to accommodate all users.

---

## Tech Stack

- **Language:** Swift 5+
- **Framework:** SwiftUI
- **Minimum iOS Version:** iOS 14.0
- **Architecture Pattern:** MVVM (Model-View-ViewModel)
- **Package Manager:** Swift Package Manager (SPM)
- **Third-Party Libraries:**
- Kingfisher (Image loading and caching)
- Alamofire (Networking)
- RevenueCat (In-app purchases)
- Facebook SDK (Social login)
- Google Sign-In SDK (Social login)

---

## Design Principles

- **User-Centered Design:** Focused on the needs and preferences of the target audience.
- **Simplicity and Clarity:** Clean interfaces with intuitive navigation.
- **Consistency:** Adherence to iOS Human Interface Guidelines.
- **Accessibility:** Support for Dynamic Type, VoiceOver, and other accessibility features.
- **Responsiveness:** Smooth transitions and interactions.

---

## Architecture

### MVVM Pattern

- **Model:** Data structures representing the application's data (e.g., `UserPreferences`, `Restaurant`).
- **View:** SwiftUI views that present the user interface (`HomeView`, `SearchView`).
- **ViewModel:** Manages the logic and data binding between Models and Views (`HomeViewModel`, `SearchViewModel`).

---

## UI Components

### Views

1. **AuthenticationView**
- Allows users to sign in using Apple, Facebook, Google, or continue as guest.
- Handles biometric authentication setup.

2. **HomeView**
- Displays personalized restaurant recommendations.
- Access to the spin wheel feature for subscribers.

3. **SearchView**
- Provides search functionality for restaurants or dishes.
- Includes filtering options based on preferences.

4. **RestaurantListView**
- Shows a list of restaurants matching the user's criteria.

5. **RestaurantDetailView**
- Detailed information about a selected restaurant.
- Includes menu, prices, ratings, and "Order Now" affiliate link.

6. **PreferencesView**
- Interface for users to input or update their dietary preferences and cravings.

7. **SpinWheelView**
- Interactive spin wheel for decision-making.
- Accessible to subscribed users.

8. **ProfileView**
- User account details, subscription management, and settings.

### Reusable Components

- **SearchBar**
- Custom search bar with text input and search icon.
- **RestaurantRowView**
- Displays restaurant information in a list.
- **SignInWithAppleButton**
- Customized sign-in button for Apple authentication.
- **CustomButton**
- Reusable button component with consistent styling.

---

## Navigation Structure

- **TabView:** Main navigation with tabs for Home, Search, Favorites, and Profile.

```swift
struct MainTabView: View {
var body: some View {
TabView {
HomeView()
.tabItem {
Label("Home", systemImage: "house")
}
SearchView()
.tabItem {
Label("Search", systemImage: "magnifyingglass")
}
FavoritesView()
.tabItem {
Label("Favorites", systemImage: "heart")
}
ProfileView()
.tabItem {
Label("Profile", systemImage: "person")
}
}
}
}
```

- **NavigationStack:** Used within each tab for in-depth navigation.

---

## State Management

### Local State

- **@State:** For view-specific properties (e.g., text fields, toggle states).

```swift
@State private var searchText: String = ""
```

### Global State

- **@ObservableObject and @Published:** For shared data across views.

```swift
class PreferencesManager: ObservableObject {
@Published var dietaryPreferences: [String] = []
}
```

- **@EnvironmentObject:** Injected into views needing access to shared data.

```swift
@EnvironmentObject var preferencesManager: PreferencesManager
```

### Data Persistence

- **UserDefaults and Keychain:** For storing user settings and sensitive data.

- **Combine Framework:** For reactive programming and handling asynchronous events.

---

## Styling and Theming

### Color Scheme

- **Assets.xcassets:** Manage color assets for light and dark mode.

- **Dynamic Colors:** Adjust colors based on system settings.

```swift
let primaryColor = Color("PrimaryColor")
```

### Typography

- **System Fonts:** Use default fonts for consistency and Dynamic Type support.

```swift
Text("Welcome to PickyEater")
.font(.headline)
```

### Custom Modifiers

- **Reusable Styles:** Create custom modifiers for consistent styling.

```swift
struct PrimaryButtonStyle: ButtonStyle {
func makeBody(configuration: Configuration) -> some View {
configuration.label
.padding()
.background(Color.accentColor)
.foregroundColor(.white)
.cornerRadius(8)
}
}
```

### Dark Mode Support

- **Automatic Adaptation:** SwiftUI handles dark mode natively.

---

## Forms and User Input

- **Forms:** Used in `PreferencesView` for structured input.

```swift
Form {
Section(header: Text("Dietary Restrictions")) {
Toggle("Vegetarian", isOn: $isVegetarian)
Toggle("Vegan", isOn: $isVegan)
}
}
```

- **Validation:** Input validation with user feedback.

```swift
if searchText.isEmpty {
Text("Please enter a search term")
.foregroundColor(.red)
}
```

---

## Accessibility Features

- **Dynamic Type:** Supports different font sizes set by the user.

- **VoiceOver Labels:** Accessibility modifiers for UI elements.

```swift
Button(action: {
// Action
}) {
Image(systemName: "heart")
}
.accessibilityLabel("Add to Favorites")
```

- **Contrast and Color Blindness:** Ensure sufficient contrast ratios and avoid relying solely on color.

- **Semantic Labels:** Use descriptive labels for images and buttons.

---

## Error Handling in UI

- **Alerts:** Display error messages using alert views.

```swift
.alert(isPresented: $showError) {
Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
}
```

- **Placeholder Content:** Inform users when data is unavailable.

```swift
if restaurants.isEmpty {
Text("No results found")
.foregroundColor(.secondary)
}
```

- **Network Connectivity:** Notify users of connectivity issues.

---

## Performance Optimization

- **Lazy Loading:** Use `LazyVStack` and `LazyHStack` for lists.

- **Image Caching:** Kingfisher handles image caching efficiently.

- **Asynchronous Loading:** Fetch data asynchronously to prevent UI blocking.

```swift
.task {
await viewModel.fetchData()
}
```

- **Minimize Re-renders:** Use `@State`, `@Binding`, and `@ObservedObject` appropriately.

---

## Testing

- **Unit Tests:** For view models and business logic.

- **UI Tests:** Validate user flows using `XCTest`.

---

## Conclusion

This frontend documentation provides a comprehensive guide for developing the user interface and user experience of **PickyEater**. Adhering to these guidelines will ensure a consistent, high-quality app that meets user needs and expectations.

