import Combine
import Foundation

actor RestaurantFilterService {
    private let preferencesManager: PreferencesManager
    private var cache: [CacheKey: [Restaurant]] = [:]
    private let cacheQueue = DispatchQueue(label: "com.pickyeater.filterservice.cache")

    struct CacheKey: Hashable {
        let preferences: UserPreferences
        let location: String // Using location string as part of cache key
        let page: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(preferences.dietaryRestrictions)
            hasher.combine(preferences.cuisinePreferences)
            hasher.combine(preferences.priceRange)
            hasher.combine(preferences.minimumRating)
            hasher.combine(preferences.maximumDistance)
            hasher.combine(location)
            hasher.combine(page)
        }
    }

    init(preferencesManager: PreferencesManager) {
        self.preferencesManager = preferencesManager
    }

    // MARK: - Public Methods

    func filterRestaurants(
        _ restaurants: [Restaurant],
        preferences: UserPreferences,
        location: String,
        page: Int = 0,
        pageSize: Int = 20
    ) async -> [Restaurant] {
        let cacheKey = CacheKey(preferences: preferences, location: location, page: page)

        // Check cache first
        if let cachedResults = await getCachedResults(for: cacheKey) {
            return cachedResults
        }

        // Apply filters in parallel using Task groups
        let filteredRestaurants = await withTaskGroup(of: [Restaurant].self) { group in
            // Split restaurants into chunks for parallel processing
            let chunks = restaurants.chunked(into: max(1, restaurants.count / ProcessInfo.processInfo.processorCount))

            for chunk in chunks {
                group.addTask {
                    chunk.filter { restaurant in
                        self.matchesPreferences(restaurant, preferences: preferences)
                    }
                }
            }

            // Combine results
            var results: [Restaurant] = []
            for await chunkResults in group {
                results.append(contentsOf: chunkResults)
            }

            return results
        }

        // Sort and paginate results
        let sortedResults = await sortRestaurantsByPreference(filteredRestaurants, preferences: preferences)
        let paginatedResults = sortedResults.paginate(page: page, pageSize: pageSize)

        // Cache the results
        await cacheResults(paginatedResults, for: cacheKey)

        return paginatedResults
    }

    func sortRestaurantsByPreference(_ restaurants: [Restaurant], preferences: UserPreferences) async -> [Restaurant] {
        // Sort in parallel using Task groups for large datasets
        return await withTaskGroup(of: [(Restaurant, Double)].self) { group in
            let chunks = restaurants.chunked(into: max(1, restaurants.count / ProcessInfo.processInfo.processorCount))

            for chunk in chunks {
                group.addTask {
                    chunk.map { restaurant in
                        (restaurant, self.calculateMatchScore(restaurant, preferences: preferences))
                    }
                }
            }

            var scoredRestaurants: [(Restaurant, Double)] = []
            for await chunkResults in group {
                scoredRestaurants.append(contentsOf: chunkResults)
            }

            return scoredRestaurants
                .sorted { $0.1 > $1.1 }
                .map { $0.0 }
        }
    }

    // MARK: - Private Methods

    private func matchesPreferences(_ restaurant: Restaurant, preferences: UserPreferences) -> Bool {
        // Price range check
        if let preferredPrice = preferences.priceRange,
           restaurant.priceRange.rawValue > preferredPrice.rawValue
        {
            return false
        }

        // Rating check
        if let minRating = preferences.minimumRating,
           restaurant.rating < minRating
        {
            return false
        }

        // Distance check
        if let maxDistance = preferences.maximumDistance,
           restaurant.distance > maxDistance
        {
            return false
        }

        // Dietary restrictions check (using Set operations for better performance)
        if !preferences.dietaryRestrictions.isEmpty {
            let restaurantCategories = Set(restaurant.categories.map { $0.lowercased() })
            let requiredCategories = Set(preferences.dietaryRestrictions.map { $0.rawValue })
            if !requiredCategories.isSubset(of: restaurantCategories) {
                return false
            }
        }

        // Cuisine preferences check (using Set operations for better performance)
        if !preferences.cuisinePreferences.isEmpty {
            let restaurantCuisines = Set(restaurant.categories.map { $0.lowercased() })
            let preferredCuisines = Set(preferences.cuisinePreferences.map { $0.lowercased() })
            if restaurantCuisines.isDisjoint(with: preferredCuisines) {
                return false
            }
        }

        return true
    }

    private func calculateMatchScore(_ restaurant: Restaurant, preferences: UserPreferences) -> Double {
        var score = 0.0
        let maxScore = 100.0

        // Price match (20 points)
        if let pricePreference = preferences.priceRange {
            score += (1.0 - Double(abs(Int(restaurant.priceRange.rawValue) - Int(pricePreference.rawValue))) / 3.0) * 20
        }

        // Dietary restrictions match (30 points)
        if !preferences.dietaryRestrictions.isEmpty {
            let restaurantCategories = Set(restaurant.categories.map { $0.lowercased() })
            let matchingRestrictions = preferences.dietaryRestrictions.filter { restriction in
                restaurantCategories.contains(restriction.rawValue)
            }
            score += Double(matchingRestrictions.count) / Double(preferences.dietaryRestrictions.count) * 30
        }

        // Cuisine preferences match (25 points)
        if !preferences.cuisinePreferences.isEmpty {
            let restaurantCuisines = Set(restaurant.categories.map { $0.lowercased() })
            let preferredCuisines = Set(preferences.cuisinePreferences.map { $0.lowercased() })
            let matchingCuisines = restaurantCuisines.intersection(preferredCuisines)
            score += Double(matchingCuisines.count) / Double(preferences.cuisinePreferences.count) * 25
        }

        // Rating match (15 points)
        if let minRating = preferences.minimumRating {
            score += (restaurant.rating >= minRating ? 15 : (restaurant.rating / minRating) * 15)
        }

        // Distance match (10 points)
        if let maxDistance = preferences.maximumDistance {
            score += (1.0 - min(restaurant.distance / maxDistance, 1.0)) * 10
        }

        return min(score, maxScore)
    }

    // MARK: - Cache Management

    private func getCachedResults(for key: CacheKey) async -> [Restaurant]? {
        await withCheckedContinuation { continuation in
            cacheQueue.async {
                continuation.resume(returning: self.cache[key])
            }
        }
    }

    private func cacheResults(_ results: [Restaurant], for key: CacheKey) async {
        await withCheckedContinuation { continuation in
            cacheQueue.async {
                self.cache[key] = results
                continuation.resume()
            }
        }
    }

    func clearCache() async {
        await withCheckedContinuation { continuation in
            cacheQueue.async {
                self.cache.removeAll()
                continuation.resume()
            }
        }
    }
}

// MARK: - Array Extensions

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

    func paginate(page: Int, pageSize: Int) -> [Element] {
        let start = page * pageSize
        let end = Swift.min(start + pageSize, count)
        guard start < count else { return [] }
        return Array(self[start ..< end])
    }
}
