//
//  WebserviceTests.swift
//  EventusAPITests
//
//  Created by Simon Gaus on 12.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import XCTest

@testable import EventusAPI

class WebserviceTests: XCTestCase {
    
    var service: Webservice!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.service = Webservice.init(baseURL: URL.init(string: "http://localhost:10439")!, session: URLSession.init(configuration: .default), apiKey: "TEST_API_KEY_001", apiVersion: .v0_1)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Manage Objects Testing
    
    func testFetch() throws {
        
        let expectation = self.expectation(description: "Fetch request")
        var testResult: Bool = false
        
        self.service.fetch("festival", with: [1,2], including: ["image"]) { (objects, err) -> (Void) in
            
            testResult = (objects != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch successfull")
    }
    
    func testCreateUpdateDeleteObject() throws {
        
        let expectation = self.expectation(description: "Create, update and delete request")
        var created: Bool = false
        var updated: Bool = false
        var deleted: Bool = false
        
        let festivalDict: [String: Any] = ["festival_id": 0, "festival_version": "", "festival_is_valid": false, "festival_name": "TESTFESTIVAL",
                                           "festival_start": 100, "festival_end": 200, "festival_description": "TESTFESTIVALDESCRIPTION", "festival_price": "1.000.000 Euro"]
        let festival = Festival.init(with: festivalDict)
        guard let jsonData = festival?.JSON() else {
            created = false
            expectation.fulfill()
            return
        }
        
        self.service.create("festival", with: jsonData) { (object, error) -> (Void) in
            
            guard let object = object as? [String: Any] else {
                created = false
                expectation.fulfill()
                return
            }
            guard var createdFestival = Festival.init(with: object) else {
                created = false
                expectation.fulfill()
                return
            }
            
            created = true
            createdFestival.name = "ANOTHERNAME"
            let updatedJsonData = createdFestival.JSON()
            
            self.service.update("festival", with: createdFestival.objectID, and: updatedJsonData) { (object, error) -> (Void) in
                
                guard let object = object as? [String: Any] else {
                    updated = false
                    expectation.fulfill()
                    return
                }
                guard let updatedFestival = Festival.init(with: object) else {
                    updated = false
                    expectation.fulfill()
                    return
                }
                
                updated = updatedFestival.name == "ANOTHERNAME"
                
                self.service.delete("festival", with: updatedFestival.objectID) { (success, error) -> (Void) in
                    
                    deleted = success
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(created, "Creation successfull")
        XCTAssert(updated, "Update successfull")
        XCTAssert(deleted, "Deletion successfull")
    }
    
    // MARK: Search Testing
    
    func testSearch() throws {
        
        let expectation = self.expectation(description: "Search request")
        var testResult: Bool = false
        
        self.service.search("festival", with: "krach") { (objects, err) -> (Void) in
            
            testResult = (objects != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch successfull")
    }
    
    // MARK: Manage Resources Testing
    
    func testFetchResource() throws {
        
        let expectation = self.expectation(description: "Fetch request")
        var testResult: Bool = false
        
        self.service.fetchResource("events", for: "festival", with: 1, including: ["artist,location"]) { (resources, err) -> (Void) in
            
            testResult = (resources != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch successfull")
    }
    
    func testResourceSetAndRemove() throws {
        
        let expectation = self.expectation(description: "Set and remove resource request")
        var setResult: Bool = false
        var removeResult: Bool = false
        
        self.service.setResource("links", with: 2, for: "festival", with: 2) { success, error in
            setResult = success
            self.service.removeResource("links", with: 2, for: "festival", with: 2) { success, error in
                
                removeResult = success
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(setResult, "Set resource successfull")
        XCTAssert(removeResult, "Remove resource successfull")
    }
    
    // MARK: Perform Request Testing
    
    func testPerform() throws {
        
        let expectation = self.expectation(description: "Perform request")
        let request = URLRequest.init(url: URL.init(string: "http://localhost:10439/festivals?ids=1,2")!)
        var testResult: Bool = false
        
        self.service.perfrom(request) { (data, err) -> (Void) in
            
            testResult = (data != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Request successfull")
    }
    
    // MARK: Query Creation Testing
    
    func testServiceFetchQueryCreation() throws {
        
        // fetchQuery(with objectType: String, _ objectIDs: [Int]?, including relationships: [String]?) -> String
        let allFestivals = self.service.makeFetchQuery(with: "festival")
        XCTAssertTrue(allFestivals == "/festivals", "Function makeFetchQuery() produced a wrong query.")
        
        let festivalWithInclude = self.service.makeFetchQuery(with: "festival", [1], including:["image", "tag"])
        XCTAssertTrue(festivalWithInclude == "/festivals/1?include=image,tag", "Function makeFetchQuery() produced a wrong query.")
        
        let twoFestivals = self.service.makeFetchQuery(with: "festival", [1,2])
        XCTAssertTrue(twoFestivals == "/festivals?ids=1,2", "Function makeFetchQuery() produced a wrong query.")
    }
}
