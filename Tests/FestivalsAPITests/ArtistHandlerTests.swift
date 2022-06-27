//
//  ArtistHandlerTests.swift
//  FestivalsAPITests
//
//  Created by Simon Gaus on 26.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import XCTest

@testable import FestivalsAPI

class ArtistHandlerTests: XCTestCase {
    
    var webservice: Webservice!
    var handler: ArtistHandler!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard let urlValue = Bundle(for: Self.self).object(forInfoDictionaryKey: "FestivalsAPI_URL") as? String else { return }
        self.webservice = Webservice.init(baseURL: URL.init(string: urlValue)!, apiKey: "TEST_API_KEY_001", apiVersion: .v0_1)
        self.handler = ArtistHandler.init(with: self.webservice)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Fetch Artists Testing
    
    func testFetchAllArtists() throws {
        
        self.webservice.calculateDiskStorageSize { result in
            
            guard let size = try? result.get() else { return }
            
            let byteCountFormatter = ByteCountFormatter()
            print("on disc: \(byteCountFormatter.string(fromByteCount: Int64(size)))")
        }
        
        let expectation = self.expectation(description: "Fetch all artists")
        var testResult: Bool = false
        
        self.handler.all { (artists, error) in
            testResult = (artists != nil)
            self.handler.all { (artists, error) in
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch all artists successfull")
    }
    
    func testFetchArtists() throws {
        
        let expectation = self.expectation(description: "Fetch some artists")
        var testResult: Bool = false
        
        self.handler.artists(with: [1,2]) { (artists, error) in
            testResult = (artists?.count == 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch some artists successfull")
    }
    
    func testFetchArtist() throws {
        
        let expectation = self.expectation(description: "Fetch an artist")
        var testResult: Bool = false
        
        self.handler.artist(with: 1) { (artist, error) in
            testResult = (artist != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch an artist successfull")
    }
    
    // MARK: Manage Artists Testing
    
    func testArtistCreationAndDeletion() throws {
        
        let expectation = self.expectation(description: "Fetch all artists")
        var createdTheArtist: Bool = false
        var deltedTheArtist: Bool = false
        
        let artistDict: [String: Any] = ["artist_id": 0, "artist_version": "", "artist_name": "TESTARTIST", "artist_description": "TESTARTISTDESCRIPTION"]
        let artist = Artist.init(with: artistDict)!
        
        self.handler.create(artist: artist) { (createdArtist, error) in
            
            guard let createdArtist = createdArtist else {
                expectation.fulfill()
                return
            }
            
            createdTheArtist = true
            
            self.handler.delete(artist: createdArtist) { (delted, error) in
                
                deltedTheArtist = delted
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheArtist, "Created artist successfull")
        XCTAssert(deltedTheArtist, "Deleted artist successfull")
    }
    
    func testArtistUpdating() throws {
        
        let expectation = self.expectation(description: "Fetch all artists")
        var createdTheArtist: Bool = false
        var updatedTheArtist: Bool = false
        var deltedTheArtist: Bool = false
        
        let artistDict: [String: Any] = ["artist_id": 0, "artist_version": "", "artist_name": "TESTARTIST", "artist_description": "TESTARTISTDESCRIPTION"]
        let artist = Artist.init(with: artistDict)!
        
        self.handler.create(artist: artist) { (createdArtist, error) in
            
            guard let createdArtist = createdArtist else {
                expectation.fulfill()
                return
            }
            
            createdTheArtist = true
            
            createdArtist.name = "ANOTHERNAME"
            createdArtist.description = "ANOTHERTESTARTISTDESCRIPTION"
            
            self.handler.update(artist: createdArtist) { (updatedArtist, error) in
                
                guard let updatedArtist = updatedArtist else {
                    expectation.fulfill()
                    return
                }
                
                updatedTheArtist = (updatedArtist.name == "ANOTHERNAME") && (updatedArtist.description == "ANOTHERTESTARTISTDESCRIPTION")
                
                self.handler.delete(artist: updatedArtist) { (delted, error) in
                    
                    deltedTheArtist = delted
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheArtist, "Created artist successfull")
        XCTAssert(updatedTheArtist, "Updated artist successfull")
        XCTAssert(deltedTheArtist, "Deleted artist successfull")
    }
    
    // MARK: Manage Links Testing
    
    func testFetchArtistLinks() throws {
        
        let expectation = self.expectation(description: "Fetch artist links")
        var testResult: Bool = false
        
        self.handler.links(for: 1) { (links, error) in
            
            testResult = (links != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch links successfull")
    }
    
    func testSetAndRemoveArtistLink() throws {
        
        let expectation = self.expectation(description: "Set and remove artist link")
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
    
    // MARK: Manage Tags Testing
    
    func testFetchArtistTags() throws {
        
        let expectation = self.expectation(description: "Fetch artist tags")
        var testResult: Bool = false
        
        self.handler.tags(for: 1) { (tags, error) in
            
            testResult = (tags != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch tags successfull")
    }
    
    func testSetAndRemoveArtistTag() throws {
        
        let expectation = self.expectation(description: "Set and remove artist tag")
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
    
    func testFetchArtistImageRef() throws {
        
        let expectation = self.expectation(description: "Fetch artist image")
        var testResult: Bool = false
        
        self.handler.image(for: 1) { (imageRef, error) in
            
            testResult = (imageRef != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch image successfull")
    }
    
    func testSetAndRemoveArtistImage() throws {
        
        let expectation = self.expectation(description: "Set and remove artist image")
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
