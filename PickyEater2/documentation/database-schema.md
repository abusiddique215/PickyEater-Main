## Documentation/database-schema.md

# Database Schema Documentation for PickyEater

[**View this document as part of the PickyEater project documentation.**](#)

---

**Table of Contents**

- [Data Models](#data-models)
- [Storage Solutions](#storage-solutions)
- [Data Flow](#data-flow)
- [Security Measures](#security-measures)
- [Conclusion](#conclusion)

---

## Data Models

### UserPreferences

- **Attributes:**

- `dietaryRestrictions`: [String]
- `favoriteCuisines`: [String]
- `cravings`: [String]
- `location`: String
- `isSubscribed`: Bool

### AuthenticationData

- **Attributes:**

- `userID`: String
- `authToken`: String
- `provider`: String (e.g., "Apple", "Facebook")

### SubscriptionReceipt

- **Attributes:**

- `receiptData`: Data
- `expiryDate`: Date
- `isValid`: Bool

---

## Storage Solutions

- **UserDefaults:** For non-sensitive user preferences.
- **Keychain:** For authentication tokens and subscription receipts.
- **Core Data (Optional):** If complex data storage is required in the future.

---

## Data Flow

- **Retrieval:** Access user preferences from storage during app launch.
- **Update:** Save changes immediately after the user updates preferences.
- **Syncing:** Not required as all data is local.

---

## Security Measures

- **Encryption:** Keychain handles encryption for sensitive data.
- **Data Protection:** Set appropriate Data Protection classes for stored files.

---

## Conclusion

Effective local data management ensures a seamless user experience while maintaining security and privacy standards.
