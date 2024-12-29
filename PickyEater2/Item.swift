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
    @Attribute private var dietaryRestrictionsData: Data = Data()
    @Attribute private var cuisinePreferencesData: Data = Data()
    var priceRange: String = "$$"
    var maxDistance: Double = 5.0
    var lastUpdated: Date = Date()
    
    var dietaryRestrictions: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: dietaryRestrictionsData)) ?? []
        }
        set {
            dietaryRestrictionsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    var cuisinePreferences: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: cuisinePreferencesData)) ?? []
        }
        set {
            cuisinePreferencesData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    init() {}
    
    init(dietaryRestrictions: [String], 
         cuisinePreferences: [String], 
         priceRange: String, 
         maxDistance: Double) {
        self.dietaryRestrictionsData = (try? JSONEncoder().encode(dietaryRestrictions)) ?? Data()
        self.cuisinePreferencesData = (try? JSONEncoder().encode(cuisinePreferences)) ?? Data()
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
