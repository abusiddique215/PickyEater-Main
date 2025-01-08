## Documentation/code-documentation.md

# Code Documentation Guidelines for PickyEater

[**View this document as part of the PickyEater project documentation**]

---

**Table of Contents**

- [Overview](#overview)
- [Documentation Standards](#documentation-standards)
- [Inline Comments](#inline-comments)
- [Function and Method Documentation](#function-and-method-documentation)
- [Class and Struct Documentation](#class-and-struct-documentation)
- [API Documentation](#api-documentation)
- [Documentation Tools](#documentation-tools)
- [Best Practices](#best-practices)
- [Conclusion](#conclusion)

---

## Overview

Proper code documentation facilitates team collaboration, eases maintenance, and helps new developers understand the codebase.

---

## Documentation Standards

- **Language**: All comments and documentation should be in English.
- **Style**: Use Apple's recommended documentation style.

---

## Inline Comments

- Use inline comments sparingly to explain complex logic.
- Do not state the obvious; code should be self-explanatory where possible.

```swift
// Check if the user is subscribed before showing premium features
if user.isSubscribed {
showPremiumContent()
}
```

---

## Function and Method Documentation

- Use triple-slash comments `///` for methods, including descriptions and parameter explanations.

```swift
/// Fetches restaurants based on user preferences.
///
/// - Parameters:
/// - location: The user's current location.
/// - completion: Closure called with results or error.
/// - Returns: Void
func fetchRestaurants(location: CLLocation, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
// ...
}
```

---

## Class and Struct Documentation

- Provide a high-level overview of the purpose and functionality.

```swift
/// Manages user authentication and session handling.
class AuthenticationService {
// ...
}
```

---

## API Documentation

- Document all public APIs and interfaces.
- Provide usage examples where appropriate.

---

## Documentation Tools

- **Xcode Quick Help**: Use `Option + Click` to view documentation.
- **Jazzy**: Generate HTML documentation from code comments.

---

## Best Practices

- **Keep Documentation Up-to-Date**

- Update comments and documentation when code changes.

- **Consistency**

- Follow consistent formatting and style throughout the codebase.

- **Clarity**

- Use clear and concise language.

---

## Conclusion

Maintaining thorough and accurate code documentation enhances code quality and developer productivity, ensuring the long-term success of **PickyEater**.

