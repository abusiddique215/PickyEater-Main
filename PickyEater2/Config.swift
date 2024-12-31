import Foundation

enum Config {
    static let yelpAPIKey = "66FqVibmo8LAv3zTD3fxxrzgkewb6uAJWBmkXQ5zQgu3PlC8sl0T2F7PuUdxXgZqdhr8NoXc9xueluXgbiGc1hFJqhu6Pnw2ZUXeM9EpxJEMmNuQt9JkOQmcZ6hxZ3Yx"
    
    static func validateAPIKeys() {
        assert(!yelpAPIKey.contains("YOUR_"), "Please set your Yelp API key in Config.swift")
    }
} 