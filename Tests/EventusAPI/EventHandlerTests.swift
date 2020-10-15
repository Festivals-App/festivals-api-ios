//
//  EventHandlerTests.swift
//  EventusAPITests
//
//  Created by Simon Gaus on 29.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import XCTest

@testable import EventusAPI

class EventHandlerTests: XCTestCase {
    
    var webservice: Webservice!
    var handler: EventHandler!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.webservice = Webservice.init(baseURL: URL.init(string: "http://localhost:10439")!, session: URLSession.init(configuration: .default), apiKey: "TEST_API_KEY_001", apiVersion: .v0_1)
        self.handler = EventHandler.init(with: self.webservice)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Fetch Events Testing
    
    func testFetchAllEvents() throws {
        
        let expectation = self.expectation(description: "Fetch all events")
        var testResult: Bool = false
        
        self.handler.all { (events, error) -> (Void) in
            testResult = (events != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch all events successfull")
    }
    
    func testFetchEvents() throws {
        
        let expectation = self.expectation(description: "Fetch some events")
        var testResult: Bool = false
        
        self.handler.events(with: [1,2]) { (events, error) -> (Void) in
            testResult = (events?.count == 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch some events successfull")
    }
    
    func testFetchEvent() throws {
        
        let expectation = self.expectation(description: "Fetch a event")
        var testResult: Bool = false
        
        self.handler.event(with: 1) { (event, error) -> (Void) in
            testResult = (event != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch a festival successfull")
    }
    
    // MARK: Manage Events Testing
    
    func testEventCreationAndDeletion() throws {
        
        let expectation = self.expectation(description: "Create and delete an event")
        var createdTheEvent: Bool = false
        var deltedTheEvent: Bool = false

        let eventDict: [String: Any] = ["event_id": 0, "event_version": "", "event_name": "TESTEVENT",
                                           "event_start": 100, "event_end": 200, "event_description": "TESTEVENTDESCRIPTION"]
        let event = Event.init(with: eventDict)!

        self.handler.create(event: event) { (createdEvent, error) -> (Void) in
            
            guard let createdEvent = createdEvent else {
                expectation.fulfill()
                return
            }
            
            createdTheEvent = true
            
            self.handler.delete(event: createdEvent) { (delted, error) -> (Void) in
                
                deltedTheEvent = delted
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheEvent, "Created an event successfull")
        XCTAssert(deltedTheEvent, "Deleted a event successfull")
    }
    
    func testFestivalUpdating() throws {
        
        let expectation = self.expectation(description: "Update an event")
        var createdTheEvent: Bool = false
        var updatedTheEvent: Bool = false
        var deltedTheEvent: Bool = false
        
        let eventDict: [String: Any] = ["event_id": 0, "event_version": "", "event_name": "TESTEVENT",
                                           "event_start": 100, "event_end": 200, "event_description": "TESTEVENTDESCRIPTION"]
        let event = Event.init(with: eventDict)!
        
        self.handler.create(event: event) { (createdEvent, error) -> (Void) in
            
            guard var createdEvent = createdEvent else {
                expectation.fulfill()
                return
            }
            
            createdTheEvent = true
            
            createdEvent.name = "ANOTHERNAME"
            
            self.handler.update(event: createdEvent) { (updatedEvent, error) -> (Void) in
                
                guard let updatedEvent = updatedEvent else {
                    expectation.fulfill()
                    return
                }
                
                updatedTheEvent = (updatedEvent.name == "ANOTHERNAME")
                
                self.handler.delete(event: updatedEvent) { (delted, error) -> (Void) in
                    
                    deltedTheEvent = delted
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheEvent, "Created event successfull")
        XCTAssert(updatedTheEvent, "Updated event successfull")
        XCTAssert(deltedTheEvent, "Deleted event successfull")
    }
    
    // MARK: Manage Artists Testing
    
    func testFetchEventArtist() throws {
        
        let expectation = self.expectation(description: "Fetch event artist")
        var testResult: Bool = false
        
        self.handler.artist(for: 1) { (artist, error) -> (Void) in
            
            testResult = (artist != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch artist successfull")
    }
    
    func testSetAndRemoveEventArtist() throws {
        
        let expectation = self.expectation(description: "Set and remove event artist")
        var didSetArtist: Bool = false
        var didRemoveArtist: Bool = false
        var didSetOldArtist: Bool = false
        
        self.handler.set(artistID: 2, for: 1) { (setSuccessfully, error) -> (Void) in
            
            didSetArtist = setSuccessfully
     
            self.handler.remove(artistID: 2, for: 1) { (removedSuccessfully, error) -> (Void) in
                
                didRemoveArtist = removedSuccessfully
                
                self.handler.set(artistID: 2, for: 1) { (setOldSuccessfully, error) -> (Void) in
                    
                    didSetOldArtist = setOldSuccessfully
                    
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didSetArtist, "Set artist successfull")
        XCTAssert(didSetOldArtist, "Set old artist successfull")
        XCTAssert(didRemoveArtist, "Remove artist successfull")
    }
    
    // MARK: Manage Place Testing
    
    func testFetchEventLocation() throws {
        
        let expectation = self.expectation(description: "Fetch event location")
        var testResult: Bool = false
        
        self.handler.location(for: 1) { (location, error) -> (Void) in
            
            testResult = (location != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch location successfull")
    }
    
    func testSetAndRemoveEventLocation() throws {
        
        let expectation = self.expectation(description: "Set and remove festival place")
        var didSetLocation: Bool = false
        var didRemoveLocation: Bool = false
        var didSetOldLocation: Bool = false
        
        self.handler.set(locationID: 2, for: 1) { (setSuccessfully, error) -> (Void) in
            
            didSetLocation = setSuccessfully
      
            self.handler.remove(locationID: 2, for: 1) { (removedSuccessfully, error) -> (Void) in
                
                didRemoveLocation = removedSuccessfully
                
                self.handler.set(locationID: 2, for: 1) { (setOldSuccessfully, error) -> (Void) in
                    
                    didSetOldLocation = setOldSuccessfully
                    
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didSetLocation, "Set location successfull")
        XCTAssert(didRemoveLocation, "Remove location successfull")
        XCTAssert(didSetOldLocation, "Set old location successfull")
    }
}

