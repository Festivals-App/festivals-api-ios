//
//  PlaceHandlerTests.swift
//  FestivalsAPITests
//
//  Created by Simon Gaus on 02.05.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import XCTest

@testable import FestivalsAPI

class PlaceHandlerTests: XCTestCase {
    
    var webservice: Webservice!
    var handler: PlaceHandler!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard let urlValue = Bundle(for: Self.self).object(forInfoDictionaryKey: "FestivalsAPI_URL") as? String else { return }
        self.webservice = Webservice.init(baseURL: URL.init(string: urlValue)!, session: URLSession.init(configuration: .default), apiKey: "TEST_API_KEY_001", apiVersion: .v0_1)
        self.handler = PlaceHandler.init(with: self.webservice)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Fetch Places Testing
    
    func testFetchAllPlaces() throws {
        
        let expectation = self.expectation(description: "Fetch all places")
        var testResult: Bool = false
        
        self.handler.all { (places, error) -> (Void) in
            testResult = (places != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch all places successfull")
    }
    
    func testFetchPlaces() throws {
        
        let expectation = self.expectation(description: "Fetch some places")
        var testResult: Bool = false
        
        self.handler.places(with: [1,2]) { (places, error) -> (Void) in
            testResult = (places?.count == 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch some places successfull")
    }
    
    func testFetchPlace() throws {
        
        let expectation = self.expectation(description: "Fetch a event")
        var testResult: Bool = false
        
        self.handler.place(with: 1) { (event, error) -> (Void) in
            testResult = (event != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetched an place successfull")
    }
    
    // MARK: Manage Places Testing
    
    func testPlaceCreationAndDeletion() throws {
        
        let expectation = self.expectation(description: "Create and delete an event")
        var createdThePlace: Bool = false
        var deltedThePlace: Bool = false
        
        let placeDict: [String: Any] = ["place_id": 0, "place_version": "", "place_street": "TESTPLACESTREET", "place_zip": "111111", "place_town": "TESTPLACETOWN", "place_street_addition": "TESTPLACEADDITION", "place_country": "TESTPLACECOUNTRY", "place_lat": 30.120101, "place_lon": 30.652101, "place_description": "TESTPLACEDESCRIPTION"]
        let place = Place.init(with: placeDict)!

        self.handler.create(place: place) { (createdPlace, error) -> (Void) in
            
            guard let createdPlace = createdPlace else {
                expectation.fulfill()
                return
            }
            
            createdThePlace = true
            
            self.handler.delete(place: createdPlace) { (delted, error) -> (Void) in
                
                deltedThePlace = delted
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdThePlace, "Created an place successfull")
        XCTAssert(deltedThePlace, "Deleted an place successfull")
    }
    
    func testPlaceUpdating() throws {
        
        let expectation = self.expectation(description: "Update an event")
        var createdThePlace: Bool = false
        var updatedThePlace: Bool = false
        var deltedThePlace: Bool = false
        
        let placeDict: [String: Any] = ["place_id": 0, "place_version": "", "place_street": "TESTPLACESTREET", "place_zip": "111111", "place_town": "TESTPLACETOWN", "place_street_addition": "TESTPLACEADDITION", "place_country": "TESTPLACECOUNTRY", "place_lat": 30.120101, "place_lon": 30.652101, "place_description": "TESTPLACEDESCRIPTION"]
        let place = Place.init(with: placeDict)!
        
        self.handler.create(place: place) { (createdPlace, error) -> (Void) in
            
            guard var createdPlace = createdPlace else {
                expectation.fulfill()
                return
            }
            
            createdThePlace = true
            
            createdPlace.street = "ANOTHERSTREET"
            
            self.handler.update(place: createdPlace) { (updatedPlace, error) -> (Void) in
                
                guard let updatedPlace = updatedPlace else {
                    expectation.fulfill()
                    return
                }
                
                updatedThePlace = (updatedPlace.street == "ANOTHERSTREET")
                
                self.handler.delete(place: updatedPlace) { (delted, error) -> (Void) in
                    
                    deltedThePlace = delted
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdThePlace, "Created event successfull")
        XCTAssert(updatedThePlace, "Updated event successfull")
        XCTAssert(deltedThePlace, "Deleted event successfull")
    }
}
