## Documentation/api.md

# API Documentation for PickyEater

[**View this document as part of the PickyEater project documentation.**](#)

---

**Table of Contents**

- [Yelp Fusion API](#yelp-fusion-api)
- [Affiliate Links Integration](#affiliate-links-integration)
- [Error Handling](#error-handling)
- [Security Considerations](#security-considerations)
- [Conclusion](#conclusion)

---

## Yelp Fusion API

**Base URL:** `https://api.yelp.com/v3`

### Authentication

- **API Key Authentication:** Include API key in the `Authorization` header.

```swift
request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
```

### Search Businesses Endpoint

- **Endpoint:** `/businesses/search`

- **Parameters:**

- `term` (Optional): Search term (e.g., "sushi").
- `location` or `latitude` & `longitude`: User location.
- `categories`: Dietary preferences (e.g., "vegan").
- `limit`: Number of results.
- `sort_by`: `best_match`, `rating`, `distance`.

### Business Details Endpoint

- **Endpoint:** `/businesses/{id}`

- **Usage:** Retrieve detailed information about a specific restaurant.

---

## Affiliate Links Integration

### Platforms

- **Uber Eats, DoorDash, Grubhub**

### Affiliate Programs

- **Enrollment:** Required for each platform.

- **Link Handling:**

- Construct affiliate links according to each platform's guidelines.
- Open links using `Link` or `SafariViewController`.

---

## Error Handling

- **HTTP Errors:**

- Handle status codes and provide user-friendly messages.

- **Network Errors:**

- Detect connectivity issues and inform the user.

---

## Security Considerations

- **API Key Storage:**

- Avoid hardcoding API keys.
- Use secure methods like Keychain or encrypted configuration files.

- **SSL Pinning (Optional):**

- Enhance security by ensuring connections are made to trusted servers.

---

## Conclusion

Proper integration with external APIs is essential for **PickyEater**'s functionality. This documentation ensures that API interactions are secure, efficient, and reliable.

