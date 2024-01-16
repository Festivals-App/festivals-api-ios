//
//  EventHandlerTests.swift
//  FestivalsAPITests
//
//  Created by Simon Gaus on 29.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import XCTest

@testable import FestivalsAPI

class EventHandlerTests: XCTestCase {
    
    var webservice: Webservice!
    var handler: EventHandler!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard let urlValue = Bundle(for: Self.self).object(forInfoDictionaryKey: "FestivalsAPI_URL") as? String else { return }
        guard let localCAPath = Bundle(for: Self.self).url(forResource: "ca", withExtension: "der") else { return }
        guard let caData = try? Data(contentsOf: localCAPath) else { return }
        guard let localCertPath = Bundle(for: Self.self).url(forResource: "api-client", withExtension: "p12") else { return }
        guard let certData = try? Data(contentsOf: localCertPath) else { return }
        guard let clientAuth = IdentityAndTrust(certData: certData  as NSData, CAData: caData as NSData, certPassword: "we4711", apiKey: "TEST_API_KEY_001") else { return }
        self.webservice = Webservice(baseURL: URL(string: urlValue)!, clientAuth: clientAuth, apiVersion: .v0_1, cached: false)
        self.handler = EventHandler(with: self.webservice)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Fetch Events Testing
    
    func testFetchAllEvents() throws {
        
        let expectation = self.expectation(description: "Fetch all events")
        var testResult: Bool = false
        
        self.handler.all { (events, error) in
            testResult = (events != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch all events successfull")
    }
    
    func testFetchEvents() throws {
        
        let expectation = self.expectation(description: "Fetch some events")
        var testResult: Bool = false
        
        self.handler.events(with: [1,2]) { (events, error) in
            testResult = (events?.count == 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch some events successfull")
    }
    
    func testFetchEvent() throws {
        
        let expectation = self.expectation(description: "Fetch a event")
        var testResult: Bool = false
        
        self.handler.event(with: 1) { (event, error) in
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
                                        "event_start": 100, "event_end": 200, "event_description": "TESTEVENTDESCRIPTION", "event_type": EventType.talk.rawValue]
        let event = Event(with: eventDict)!
        
        self.handler.create(event: event) { (createdEvent, error) in
            
            guard let createdEvent = createdEvent else {
                expectation.fulfill()
                return
            }
            
            createdTheEvent = true
            
            self.handler.delete(event: createdEvent) { (delted, error) in
                
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
                                        "event_start": 100, "event_end": 200, "event_description": "TESTEVENTDESCRIPTION", "event_type": EventType.food.rawValue]
        let event = Event(with: eventDict)!
        
        self.handler.create(event: event) { (createdEvent, error) in
            
            guard let createdEvent = createdEvent else {
                expectation.fulfill()
                return
            }
            
            createdTheEvent = true
            
            createdEvent.name = "ANOTHERNAME"
            createdEvent.type = .music
            
            self.handler.update(event: createdEvent) { (updatedEvent, error) in
                
                guard let updatedEvent = updatedEvent else {
                    expectation.fulfill()
                    return
                }
                
                updatedTheEvent = (updatedEvent.name == "ANOTHERNAME" && updatedEvent.type == .music)
                
                self.handler.delete(event: updatedEvent) { (delted, error) in
                    
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
        
        self.handler.artist(for: 1) { (artist, error) in
            
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
        
        self.handler.set(artistID: 2, for: 1) { (setSuccessfully, error) in
            
            didSetArtist = setSuccessfully
            
            self.handler.remove(artistID: 2, for: 1) { (removedSuccessfully, error) in
                
                didRemoveArtist = removedSuccessfully
                
                self.handler.set(artistID: 2, for: 1) { (setOldSuccessfully, error) in
                    
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
        
        self.handler.location(for: 1) { (location, error) in
            
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
        
        self.handler.set(locationID: 2, for: 1) { (setSuccessfully, error) in
            
            didSetLocation = setSuccessfully
            
            self.handler.remove(locationID: 2, for: 1) { (removedSuccessfully, error) in
                
                didRemoveLocation = removedSuccessfully
                
                self.handler.set(locationID: 2, for: 1) { (setOldSuccessfully, error) in
                    
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
    
    // MARK: Manage Image Testing
    
    func testFetchEventImageRef() throws {
        
        let expectation = self.expectation(description: "Fetch event image")
        var testResult: Bool = false
        
        self.handler.image(for: 1) { (imageRef, error) in
            
            testResult = (imageRef != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch image successfull")
    }
    
    func testSetAndRemoveEventImageRef() throws {
        
        let expectation = self.expectation(description: "Set and remove an event image")
        var didSetImage: Bool = false
        var didRemoveImage: Bool = false
        
        self.handler.set(imageID: 2, for: 2) { (setSuccessfully, error) in
            
            didSetImage = setSuccessfully
            
            self.handler.remove(imageID: 2, for: 2) { (removedSuccessfully, error) in
                
                didRemoveImage = removedSuccessfully
                
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(didSetImage, "Set image successfull")
        XCTAssert(didRemoveImage, "Remove image successfull")
    }
    
    func testEventTypeLocalization() throws {
        
        print("EventType.music.localizedName: \(EventType.music.localizedName)")
         
        if NSLocale.current.languageCode == "de" {
            XCTAssertTrue(EventType.music.localizedName == "Musik", "The localized name for the music event type is wrong.")
        }
        else {
            XCTAssertTrue(EventType.music.localizedName == "Music", "The localized name for the music event type is wrong.")
        }
    
    }
}

