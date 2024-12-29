//
//  Item.swift
//  PickyEater2
//
//  Created by Abu Siddique on 12/29/24.
//

import Foundation
import SwiftData

@Model
final class UserPreferences {
    var dietaryRestrictions: [String]
    var cuisinePreferences: [String]
    var priceRange: String
    var maxDistance: Double // in miles
    var lastUpdated: Date
    
    init(dietaryRestrictions: [String] = [], 
         cuisinePreferences: [String] = [], 
         priceRange: String = "$$", 
         maxDistance: Double = 5.0) {
        self.dietaryRestrictions = dietaryRestrictions
        self.cuisinePreferences = cuisinePreferences
        self.priceRange = priceRange
        self.maxDistance = maxDistance
        self.lastUpdated = Date()
    }
}

struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let rating: Double
    let price: String?
    let location: Location
    let photos: [String]?
    let categories: [Category]
    let coordinates: Coordinates
    let isClosed: Bool
    
    struct Location: Codable {
        let address1: String
        let city: String
        let state: String
        let zipCode: String
        
        enum CodingKeys: String, CodingKey {
            case address1
            case city
            case state
            case zipCode = "zip_code"
        }
    }
    
    struct Category: Codable {
        let alias: String
        let title: String
    }
    
    struct Coordinates: Codable {
        let latitude: Double
        let longitude: Double
    }
}

struct RestaurantSearchResponse: Codable {
    let businesses: [Restaurant]
    let total: Int
}
