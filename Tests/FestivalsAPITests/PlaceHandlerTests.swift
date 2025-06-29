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
        
        guard let urlValue = ProcessInfo.processInfo.environment["BASE_URL"] else {
            throw HandlerTestsError.setUpFailed(reason: "No BASE_URL environment variable set")
        }
        guard let certs = try? loadCertificates() else {
            throw HandlerTestsError.setUpFailed(reason: "Failed to load certificates")
        }
        guard let certProvider = CertificateProvider(certData: certs.1, certPassword: "we4711", rootCAData: certs.0) else {
            throw HandlerTestsError.setUpFailed(reason: "Failed to create certificate provider")
        }
        let clientAuth = ClientAuth(apiKey: "TEST_API_KEY_001", certificates: certProvider)
        self.webservice = Webservice(baseURL: URL(string: urlValue)!, clientAuth: clientAuth, apiVersion: .v0_1, cached: false)
        self.handler = PlaceHandler.init(with: self.webservice)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Fetch Places Testing
    
    func testFetchAllPlaces() throws {
        
        let expectation = self.expectation(description: "Fetch all places")
        var testResult: Bool = false
        
        self.handler.all { (places, error) in
            testResult = (places != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch all places successfull")
    }
    
    func testFetchPlaces() throws {
        
        let expectation = self.expectation(description: "Fetch some places")
        var testResult: Bool = false
        
        self.handler.places(with: [1,2]) { (places, error) in
            testResult = (places?.count == 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch some places successfull")
    }
    
    func testFetchPlace() throws {
        
        let expectation = self.expectation(description: "Fetch a event")
        var testResult: Bool = false
        
        self.handler.place(with: 1) { (event, error) in
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

        self.handler.create(place: place) { (createdPlace, error) in
            
            guard let createdPlace = createdPlace else {
                expectation.fulfill()
                return
            }
            
            createdThePlace = true
            
            self.handler.delete(place: createdPlace) { (delted, error) in
                
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
        
        self.handler.create(place: place) { (createdPlace, error) in
            
            guard var createdPlace = createdPlace else {
                expectation.fulfill()
                return
            }
            
            createdThePlace = true
            
            createdPlace.street = "ANOTHERSTREET"
            
            self.handler.update(place: createdPlace) { (updatedPlace, error) in
                
                guard let updatedPlace = updatedPlace else {
                    expectation.fulfill()
                    return
                }

                updatedThePlace = (updatedPlace.street == "ANOTHERSTREET")
                
                self.handler.delete(place: updatedPlace) { (delted, error) in
                    
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
