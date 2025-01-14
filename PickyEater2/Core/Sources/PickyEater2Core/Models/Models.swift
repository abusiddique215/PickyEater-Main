import Foundation

public struct Category: Codable, Equatable {
    public let alias: String
    public let title: String
    
    public init(alias: String, title: String) {
        self.alias = alias
        self.title = title
    }
}

public struct RestaurantSearchResponse: Codable {
    public let restaurants: [AppRestaurant]
    
    public init(restaurants: [AppRestaurant]) {
        self.restaurants = restaurants
    }
}
