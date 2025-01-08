//
//  PickyEater2Tests.swift
//  PickyEater2Tests
//
//  Created by Abu Siddique on 12/29/24.
//

@testable import PickyEater2
import XCTest

final class PickyEater2Tests: XCTestCase {
    var signInManager: SignInWithAppleManager!
    var userPreferences: UserPreferences!

    override func setUpWithError() throws {
        signInManager = SignInWithAppleManager.shared
        userPreferences = UserPreferences()
    }

    override func tearDownWithError() throws {
        signInManager = nil
        userPreferences = nil
    }

    func testUserPreferencesInitialization() throws {
        XCTAssertEqual(userPreferences.maxDistance, 5, "Default max distance should be 5km")
        XCTAssertEqual(userPreferences.priceRange, 2, "Default price range should be 2")
        XCTAssertTrue(userPreferences.dietaryRestrictions.isEmpty, "Dietary restrictions should be empty by default")
        XCTAssertTrue(userPreferences.cuisinePreferences.isEmpty, "Cuisine preferences should be empty by default")
    }

    func testUserPreferencesUpdate() throws {
        userPreferences.maxDistance = 10
        userPreferences.priceRange = 3
        userPreferences.dietaryRestrictions = ["Vegetarian"]
        userPreferences.cuisinePreferences = ["Italian"]

        XCTAssertEqual(userPreferences.maxDistance, 10, "Max distance should update to 10km")
        XCTAssertEqual(userPreferences.priceRange, 3, "Price range should update to 3")
        XCTAssertEqual(userPreferences.dietaryRestrictions, ["Vegetarian"], "Dietary restrictions should update")
        XCTAssertEqual(userPreferences.cuisinePreferences, ["Italian"], "Cuisine preferences should update")
    }

    func testSignInManagerInitialState() throws {
        XCTAssertFalse(signInManager.isAuthenticated, "User should not be authenticated initially")
        XCTAssertNil(signInManager.userIdentifier, "User identifier should be nil initially")
        XCTAssertNil(signInManager.userName, "User name should be nil initially")
        XCTAssertNil(signInManager.userEmail, "User email should be nil initially")
    }

    func testLocationManagerInitialization() throws {
        let locationManager = LocationManager()
        XCTAssertNotNil(locationManager, "Location manager should initialize")
    }

    @MainActor
    func testThemeManagerInitialization() throws {
        let themeManager = ThemeManager.shared
        XCTAssertNotNil(themeManager, "Theme manager should initialize")
    }
}
