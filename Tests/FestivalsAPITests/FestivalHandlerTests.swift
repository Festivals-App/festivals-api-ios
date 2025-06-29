//
//  FestivalHandlerTests.swift
//  FestivalsAPITests
//
//  Created by Simon Gaus on 18.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import XCTest

@testable import FestivalsAPI

class FestivalHandlerTests: XCTestCase {
    
    var webservice: Webservice!
    var handler: FestivalHandler!
    
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
        self.handler = FestivalHandler.init(with: self.webservice)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Fetch Festivals Testing
    
    func testFetchAllFestivals() throws {
        
        let expectation = self.expectation(description: "Fetch all festivals")
        var testResult: Bool = false
        
        self.handler.all { (festivals, error) in
            testResult = (festivals != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch all festivals successfull")
    }
    
    func testFetchFestivals() throws {
        
        let expectation = self.expectation(description: "Fetch some festivals")
        var testResult: Bool = false
        
        self.handler.festivals(with: [1,2]) { (festivals, error) in
            testResult = (festivals?.count == 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch some festivals successfull")
    }
    
    func testFetchFestival() throws {
        
        let expectation = self.expectation(description: "Fetch a festival")
        var testResult: Bool = false
        
        self.handler.festival(with: 1) { (festival, error) in
            testResult = (festival != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch a festival successfull")
    }
    
    func testSearchFestivals() throws {
        
        let expectation = self.expectation(description: "Search for festivals")
        var testResult: Bool = false
        
        self.handler.search(with: "krach") { festivals, error in
            
            testResult = (festivals?.count == 1)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Search for festivals successfull")
    }
    
    // MARK: Manage Festivals Testing
    
    func testFestivalCreationAndDeletion() throws {
        
        let expectation = self.expectation(description: "Create and delete a festival")
        var createdTheFestival: Bool = false
        var deltedTheFestival: Bool = false
        
        let festivalDict: [String: Any] = ["festival_id": 0, "festival_version": "", "festival_is_valid": false, "festival_name": "TESTFESTIVAL",
                                           "festival_start": 100, "festival_end": 200, "festival_description": "TESTFESTIVALDESCRIPTION", "festival_price": "1.000.000 Euro"]
        let festival = Festival.init(with: festivalDict)!
        
        self.handler.create(festival: festival) { (createdFestival, error) in
            
            guard let createdFestival = createdFestival else {
                expectation.fulfill()
                return
            }
            
            createdTheFestival = true
            
            self.handler.delete(festival: createdFestival) { (delted, error) in
                
                deltedTheFestival = delted
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheFestival, "Created a festival successfull")
        XCTAssert(deltedTheFestival, "Deleted a festival successfull")
    }
    
    func testFestivalUpdating() throws {
        
        let expectation = self.expectation(description: "Update a festival")
        var createdTheFestival: Bool = false
        var updatedTheFestival: Bool = false
        var deltedTheFestival: Bool = false
        
        let festivalDict: [String: Any] = ["festival_id": 0, "festival_version": "", "festival_is_valid": false, "festival_name": "TESTFESTIVAL",
                                           "festival_start": 100, "festival_end": 200, "festival_description": "TESTFESTIVALDESCRIPTION", "festival_price": "1.000.000 Euro"]
        let festival = Festival.init(with: festivalDict)!
        
        self.handler.create(festival: festival) { (createdFestival, error) in
            
            guard let createdFestival = createdFestival else {
                expectation.fulfill()
                return
            }
            
            createdTheFestival = true
            
            createdFestival.name = "ANOTHERNAME"
            
            self.handler.update(festival: createdFestival) { (updatedFestival, error) in
                
                guard let updatedFestival = updatedFestival else {
                    expectation.fulfill()
                    return
                }
                
                updatedTheFestival = (updatedFestival.name == "ANOTHERNAME")
                
                self.handler.delete(festival: updatedFestival) { (delted, error) in
                    
                    deltedTheFestival = delted
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheFestival, "Created festival successfull")
        XCTAssert(updatedTheFestival, "Updated festival successfull")
        XCTAssert(deltedTheFestival, "Deleted festival successfull")
    }
    
    // MARK: Manage Events Testing
    
    func testFetchFestivalEvents() throws {
        
        let expectation = self.expectation(description: "Fetch festival events")
        var testResult: Bool = false
        
        self.handler.events(for: 1, with: false) { (events, error) in
            
            testResult = (events != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch events successfull")
    }
    
    func testFetchZeroFestivalEvents() throws {
        
        let expectation = self.expectation(description: "Fetch zero festival events")
        var testResult: Bool = false
        
        self.handler.events(for: 73, with: false) { (events, error) in
            
            testResult = (events != nil)
            if testResult {
                testResult = (events?.count == 0)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch events successfull")
    }
    
    func testSetFestivalEvent() throws {
        
        let expectation = self.expectation(description: "Set and reset festival link")
        
        var didCreateEvent: Bool = false
        var didSetEvent: Bool = false
        var didDeleteEvent: Bool = false
        
        let eventHandler = EventHandler.init(with: self.webservice)
        let eventDict: [String: Any] = ["event_id": 75, "event_version": "", "event_name": "TESTEVENT", "event_start": 100, "event_end": 200, "event_description": "TESTEVENTDESCRIPTION", "event_type": 0, "event_is_scheduled": true, "event_has_timeslot": true]
        let event = Event(with: eventDict)!
        
        eventHandler.create(event: event) { (createdEvent, error) in
            
            didCreateEvent = (createdEvent != nil)
            
            if didCreateEvent {
                self.handler.set(eventID: createdEvent!.objectID, for: 2) { (setSuccessfully, error) in
                    
                    didSetEvent = setSuccessfully
                    
                    eventHandler.delete(event: createdEvent!) { (deletedSuccessfully, error) in
                        
                        didDeleteEvent = deletedSuccessfully
                        expectation.fulfill()
                    }
                }
            }
            else {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didCreateEvent, "Create event successfull")
        XCTAssert(didSetEvent, "Set event successfull")
        XCTAssert(didDeleteEvent, "Delete event successfull")
    }
    
    // MARK: Manage Links Testing
    
    func testFetchFestivalLinks() throws {
        
        let expectation = self.expectation(description: "Fetch festival links")
        var testResult: Bool = false
        
        self.handler.links(for: 1) { (links, error) in
            
            testResult = (links != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch links successfull")
    }
    
    func testSetAndRemoveFestivalLink() throws {
        
        let expectation = self.expectation(description: "Set and remove festival link")
        var didSetLink: Bool = false
        var didRemoveLink: Bool = false
        
        self.handler.set(linkID: 2, for: 2) { (setSuccessfully, error) in
            
            didSetLink = setSuccessfully
     
            self.handler.remove(linkID: 2, for: 2) { (removedSuccessfully, error) in
                
                didRemoveLink = removedSuccessfully
                
                 expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didSetLink, "Set link successfull")
        XCTAssert(didRemoveLink, "Remove link successfull")
    }
    
    // MARK: Manage Place Testing
    
    func testFetchFestivalPlace() throws {
        
        let expectation = self.expectation(description: "Fetch festival place")
        var testResult: Bool = false
        
        self.handler.place(for: 1) { (place, error) in
            
            testResult = (place != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch place successfull")
    }
    
    func testSetAndRemoveFestivalPlace() throws {
        
        let expectation = self.expectation(description: "Set and remove festival place")
        var didSetPlace: Bool = false
        var didRemovePlace: Bool = false
        
        self.handler.set(placeID: 2, for: 2) { (setSuccessfully, error) in
            
            didSetPlace = setSuccessfully
      
            self.handler.remove(placeID: 2, for: 2) { (removedSuccessfully, error) in
                
                didRemovePlace = removedSuccessfully
                
                 expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didSetPlace, "Set place successfull")
        XCTAssert(didRemovePlace, "Remove place successfull")
    }
    
    // MARK: Manage Tags Testing
    
    func testFetchFestivalTags() throws {
        
        let expectation = self.expectation(description: "Fetch festival tags")
        var testResult: Bool = false
        
        self.handler.tags(for: 1) { (tags, error) in
            
            testResult = (tags != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch tags successfull")
    }
    
    func testSetAndRemoveFestivalTag() throws {
        
        let expectation = self.expectation(description: "Set and remove festival tag")
        var didSetTag: Bool = false
        var didRemoveTag: Bool = false
        
        self.handler.set(tagID: 2, for: 2) { (setSuccessfully, error) in
              
              didSetTag = setSuccessfully
        
              self.handler.remove(tagID: 2, for: 2) { (removedSuccessfully, error) in
                  
                  didRemoveTag = removedSuccessfully
                  
                   expectation.fulfill()
              }
          }
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didSetTag, "Set tag successfull")
        XCTAssert(didRemoveTag, "Remove tag successfull")
    }
    
    // MARK: Manage Image Testing
    
    func testFetchFestivalImageRef() throws {
        
        let expectation = self.expectation(description: "Fetch festival image")
        var testResult: Bool = false
        
        self.handler.image(for: 1) { (imageRef, error) in
            
            testResult = (imageRef != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch image successfull")
    }
    
    func testSetAndRemoveFestivalImage() throws {
        
        let expectation = self.expectation(description: "Set and remove festival image")
        var didSetTag: Bool = false
        var didRemoveTag: Bool = false
        
        self.handler.set(imageID: 2, for: 2) { (setSuccessfully, error) in
              
              didSetTag = setSuccessfully
        
              self.handler.remove(imageID: 2, for: 2) { (removedSuccessfully, error) in
                  
                  didRemoveTag = removedSuccessfully
                  
                   expectation.fulfill()
              }
          }
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didSetTag, "Set image successfull")
        XCTAssert(didRemoveTag, "Remove image successfull")
    }
    
}
