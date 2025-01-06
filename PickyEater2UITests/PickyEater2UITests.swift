//
//  PickyEater2UITests.swift
//  PickyEater2UITests
//
//  Created by Abu Siddique on 12/29/24.
//

import XCTest

final class PickyEater2UITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testBasicAppNavigation() throws {
        // Test tab bar navigation
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)
        XCTAssertTrue(app.tabBars.buttons["Map"].exists)
        XCTAssertTrue(app.tabBars.buttons["Profile"].exists)
        
        // Navigate to Profile
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.navigationBars["Profile"].exists)
        
        // Check for Sign in with Apple button
        let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
        XCTAssertTrue(signInButton.exists)
    }
    
    func testSearchFlow() throws {
        // Navigate to Search
        app.tabBars.buttons["Search"].tap()
        
        // Check search field exists
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.exists)
        
        // Test search interaction
        searchField.tap()
        searchField.typeText("Pizza")
        app.keyboards.buttons["Search"].tap()
        
        // Wait for results
        let predicate = NSPredicate(format: "exists == true")
        let expectation = expectation(for: predicate, evaluatedWith: app.cells.firstMatch, handler: nil)
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCuisineSelection() throws {
        // Navigate to Profile
        app.tabBars.buttons["Profile"].tap()
        
        // Tap Favorite Cuisines
        app.buttons["Favorite Cuisines"].tap()
        
        // Check if cuisine options exist
        XCTAssertTrue(app.buttons["Italian"].exists)
        XCTAssertTrue(app.buttons["Chinese"].exists)
        
        // Select a cuisine
        app.buttons["Italian"].tap()
        
        // Check if Next button is enabled
        XCTAssertTrue(app.buttons["NEXT"].isEnabled)
    }
    
    func testDarkModeToggle() throws {
        // Navigate to Profile
        app.tabBars.buttons["Profile"].tap()
        
        // Find and toggle dark mode switch
        let darkModeSwitch = app.switches.firstMatch
        XCTAssertTrue(darkModeSwitch.exists)
        darkModeSwitch.tap()
    }
}
