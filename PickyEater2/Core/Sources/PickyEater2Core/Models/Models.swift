import Foundation

public struct RestaurantSearchResponse: Codable {
    public let restaurants: [AppRestaurant]
    
    public init(restaurants: [AppRestaurant]) {
        self.restaurants = restaurants
    }
}
