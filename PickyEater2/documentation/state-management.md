## Documentation/state-management.md

# State Management Documentation for PickyEater

[**View this document as part of the PickyEater project documentation**]

---

**Table of Contents**

- [Overview](#overview)
- [State Management Approach](#state-management-approach)
- [Local State](#local-state)
- [Global State](#global-state)
- [Data Persistence](#data-persistence)
- [Combine Framework Usage](#combine-framework-usage)
- [Best Practices](#best-practices)
- [Conclusion](#conclusion)

---

## Overview

Effective state management is crucial for maintaining a responsive and consistent user experience in **PickyEater**. This document outlines the strategies used to manage local, global, and persisted state within the app.

---

## State Management Approach

**SwiftUI's state management tools** are utilized for their simplicity and integration with the UI framework:

- `@State`
- `@Binding`
- `@ObservedObject`
- `@StateObject`
- `@EnvironmentObject`
- **Combine** framework for reactive programming.

---

## Local State

### Definition

State that is specific to a single view and does not need to be shared.

### Usage

- Managed with `@State` properties.

```swift
struct SearchView: View {
@State private var searchText: String = ""
// ...
}
```

---

## Global State

### Definition

State that needs to be accessible across multiple views or throughout the app.

### Usage

- Managed with `@ObservableObject` classes and `@Published` properties.
- Injected into views with `@EnvironmentObject`.

```swift
class UserSettings: ObservableObject {
@Published var dietaryPreferences: [String] = []
// ...
}

@main
struct PickyEaterApp: App {
@StateObject private var userSettings = UserSettings()
var body: some Scene {
WindowGroup {
ContentView()
.environmentObject(userSettings)
}
}
}
```

---

## Data Persistence

### User Preferences

- Stored using **UserDefaults** for simple data.
- Managed within a controller or manager class.

```swift
class PreferencesManager: ObservableObject {
@Published var dietaryPreferences: [String] = [] {
didSet {
savePreferences()
}
}
//...
}
```

### Authentication Tokens

- Stored securely in the **Keychain**.

---

## Combine Framework Usage

### Purpose

- Handle asynchronous data streams.
- Update the UI reactively when data changes.

### Example

```swift
class RestaurantListViewModel: ObservableObject {
@Published var restaurants: [Restaurant] = []
private var cancellables = Set<AnyCancellable>()

func fetchRestaurants() {
apiService.getRestaurants()
.receive(on: DispatchQueue.main)
.sink(receiveCompletion: { completion in
// Handle errors
}, receiveValue: { [weak self] restaurants in
self?.restaurants = restaurants
})
.store(in: &cancellables)
}
}
```

---

## Best Practices

- **Avoid State Duplication**

- Ensure there's a single source of truth for each piece of data.

- **Use `@StateObject` for ViewModels**

- Initialize once per view lifecycle to avoid multiple instances.

- **Minimize `@Published` Properties**

- Only mark properties that need to trigger UI updates.

- **Clean Up Subscriptions**

- Manage `AnyCancellable` instances to prevent memory leaks.

---

## Conclusion

Using SwiftUI's built-in state management techniques, combined with the Combine framework, allows for a clean and efficient approach to managing the app's state. This results in a responsive UI and a better user experience.
