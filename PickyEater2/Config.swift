import Foundation

enum Config {
    static func validateAPIKeys() {
        let apiKey = ProcessInfo.processInfo.environment["YELP_API_KEY"] ?? ""
        assert(!apiKey.isEmpty, "Please set your Yelp API key in the environment variables or Config.swift")
    }
} 