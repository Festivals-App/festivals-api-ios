//
//  LocationHandlerTests.swift
//  EventusAPI-SwiftTests
//
//  Created by Simon Gaus on 26.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import XCTest

@testable import EventusAPI_Swift

class LocationHandlerTests: XCTestCase {
    
    var webservice: Webservice!
    var handler: LocationHandler!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.webservice = Webservice.init(baseURL: URL.init(string: "http://localhost:8080")!, session: URLSession.init(configuration: .default), apiVersion: "")
        self.handler = LocationHandler.init(with: self.webservice)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Fetch Locations Testing
    
    func testFetchAllLocations() throws {
        
        let expectation = self.expectation(description: "Fetch all locations")
        var testResult: Bool = false
        
        self.handler.all { (locations, error) -> (Void) in
            testResult = (locations != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch all locations successfull")
    }
    
    func testFetchLocations() throws {
        
        let expectation = self.expectation(description: "Fetch some locations")
        var testResult: Bool = false
        
        self.handler.locations(with: [1,2]) { (locations, error) -> (Void) in
            testResult = (locations?.count == 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch some locations successfull")
    }
    
    func testFetchLocation() throws {
        
        let expectation = self.expectation(description: "Fetch a location")
        var testResult: Bool = false
        
        self.handler.location(with: 1) { (location, error) -> (Void) in
            testResult = (location != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch a location successfull")
    }
    
    // MARK: Manage Locations Testing
    
    func testLocationCreationAndDeletion() throws {
        
        let expectation = self.expectation(description: "Create and delete a location")
        var createdTheLocation: Bool = false
        var deltedTheLocation: Bool = false
        
        let locationDict: [String: Any] = ["location_id": 0, "location_version": "", "location_name": "TESTLOCATION", "location_description": "TESTLOCATIONDESCRIPTION",
                                           "location_accessible": true, "location_openair": true]
        let location = Location.init(with: locationDict)!
        
        self.handler.create(location: location) { (createdLocation, error) -> (Void) in
            
            guard let createdLocation = createdLocation else {
                expectation.fulfill()
                return
            }
            
            createdTheLocation = true
            
            self.handler.delete(location: createdLocation) { (delted, error) -> (Void) in
                
                deltedTheLocation = delted
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheLocation, "Created a location successfull")
        XCTAssert(deltedTheLocation, "Deleted a location successfull")
    }
    
    func testLocationUpdating() throws {
        
        let expectation = self.expectation(description: "Update a location")
        var createdTheLocation: Bool = false
        var updatedTheLocation: Bool = false
        var deltedTheLocation: Bool = false
        
        let locationDict: [String: Any] = ["location_id": 0, "location_version": "", "location_name": "TESTLOCATION", "location_description": "TESTLOCATIONDESCRIPTION",
                                           "location_accessible": true, "location_openair": true]
        let location = Location.init(with: locationDict)!
        
        self.handler.create(location: location) { (createdLocation, error) -> (Void) in
            
            guard var createdLocation = createdLocation else {
                expectation.fulfill()
                return
            }
            
            createdTheLocation = (createdLocation.name == "TESTLOCATION") && (createdLocation.description == "TESTLOCATIONDESCRIPTION") && (createdLocation.accessible == true) && (createdLocation.openair == true)
            
            createdLocation.name = "CHANGEDTESTLOCATION"
            createdLocation.description = "CHANGEDTESTLOCATIONDESCRIPTION"
            createdLocation.accessible = false
            createdLocation.openair = false
            
            self.handler.update(location: createdLocation) { (updatedLocation, error) -> (Void) in
                
                guard let updatedLocation = updatedLocation else {
                    expectation.fulfill()
                    return
                }
                
                updatedTheLocation = (updatedLocation.name == "CHANGEDTESTLOCATION") && (updatedLocation.description == "CHANGEDTESTLOCATIONDESCRIPTION") && (updatedLocation.accessible == false) && (updatedLocation.openair == false)
                
                self.handler.delete(location: updatedLocation) { (delted, error) -> (Void) in
                    
                    deltedTheLocation = delted
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheLocation, "Created location successfull")
        XCTAssert(updatedTheLocation, "Updated location successfull")
        XCTAssert(deltedTheLocation, "Deleted location successfull")
    }
    
    // MARK: Manage Links Testing
    
    func testFetchLocationLinks() throws {
        
        let expectation = self.expectation(description: "Fetch location links")
        var testResult: Bool = false
        
        self.handler.links(for: 1) { (links, error) -> (Void) in
            
            testResult = (links != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch links successfull")
    }
    
    func testSetAndRemoveLocationLink() throws {
        
        let expectation = self.expectation(description: "Set and remove location link")
        var didSetLink: Bool = false
        var didRemoveLink: Bool = false
        
        self.handler.set(linkID: 2, for: 2) { (setSuccessfully, error) -> (Void) in
            
            didSetLink = setSuccessfully
     
            self.handler.remove(linkID: 2, for: 2) { (removedSuccessfully, error) -> (Void) in
                
                didRemoveLink = removedSuccessfully
                
                 expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didSetLink, "Set link successfull")
        XCTAssert(didRemoveLink, "Remove link successfull")
    }
    
    // MARK: Manage Place Testing
    
    func testFetchLocationPlace() throws {
        
        let expectation = self.expectation(description: "Fetch location place")
        var testResult: Bool = false
        
        self.handler.place(for: 1) { (place, error) -> (Void) in
            
            testResult = (place != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch place successfull")
    }
    
    func testSetAndRemoveLocationPlace() throws {
        
        let expectation = self.expectation(description: "Set and remove location place")
        var didSetPlace: Bool = false
        var didRemovePlace: Bool = false
        
        self.handler.set(placeID: 2, for: 2) { (setSuccessfully, error) -> (Void) in
            
            didSetPlace = setSuccessfully
      
            self.handler.remove(placeID: 2, for: 2) { (removedSuccessfully, error) -> (Void) in
                
                didRemovePlace = removedSuccessfully
                
                 expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didSetPlace, "Set place successfull")
        XCTAssert(didRemovePlace, "Remove place successfull")
    }
    
    // MARK: Manage Image Testing
    
    func testFetchLocationImageRef() throws {
        
        let expectation = self.expectation(description: "Fetch location image")
        var testResult: Bool = false
        
        self.handler.image(for: 1) { (imageRef, error) -> (Void) in
            
            testResult = (imageRef != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch image successfull")
    }
    
    func testSetAndRemoveLocationImage() throws {
        
        let expectation = self.expectation(description: "Set and remove location image")
        var didSetTag: Bool = false
        var didRemoveTag: Bool = false
        
        self.handler.set(imageID: 2, for: 2) { (setSuccessfully, error) -> (Void) in
              
              didSetTag = setSuccessfully
        
              self.handler.remove(imageID: 2, for: 2) { (removedSuccessfully, error) -> (Void) in
                  
                  didRemoveTag = removedSuccessfully
                  
                   expectation.fulfill()
              }
          }
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didSetTag, "Set image successfull")
        XCTAssert(didRemoveTag, "Remove image successfull")
    }
    
}
