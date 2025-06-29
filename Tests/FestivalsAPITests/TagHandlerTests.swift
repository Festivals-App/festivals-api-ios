//
//  TagHandlerTests.swift
//  FestivalsAPITests
//
//  Created by Simon Gaus on 02.05.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import XCTest

@testable import FestivalsAPI

class TagHandlerTests: XCTestCase {
    
    var webservice: Webservice!
    var handler: TagHandler!
    
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
        self.handler = TagHandler(with: self.webservice)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Fetch Tags Testing
    
    func testFetchAllTags() throws {
        
        let expectation = self.expectation(description: "Fetch all tags")
        var testResult: Bool = false
        
        self.handler.all { (tags, error) in
            testResult = (tags != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch all tags successfull")
    }
    
    func testFetchTags() throws {
        
        let expectation = self.expectation(description: "Fetch some tags")
        var testResult: Bool = false
        
        self.handler.tags(with: [1,2]) { (tags, error) in
            testResult = (tags?.count == 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch some tags successfull")
    }
    
    func testFetchTag() throws {
        
        let expectation = self.expectation(description: "Fetch a event")
        var testResult: Bool = false
        
        self.handler.tag(with: 1) { (event, error) in
            testResult = (event != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetched an tag successfull")
    }
    
    // MARK: Manage Tags Testing
    
    func testTagCreationAndDeletion() throws {
        
        let expectation = self.expectation(description: "Create and delete an event")
        var createdTheTag: Bool = false
        var deltedTheTag: Bool = false
        
        let tagDict: [String: Any] = ["tag_id": 0, "tag_name": "TESTTAG"]
        let tag = Tag.init(with: tagDict)!

        self.handler.create(tag: tag) { (createdTag, error) in
            
            guard let createdTag = createdTag else {
                expectation.fulfill()
                return
            }
            
            createdTheTag = true
            
            self.handler.delete(tag: createdTag) { (delted, error) in
                
                deltedTheTag = delted
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheTag, "Created an tag successfull")
        XCTAssert(deltedTheTag, "Deleted an tag successfull")
    }
    
    func testTagUpdating() throws {
        
        let expectation = self.expectation(description: "Update an event")
        var createdTheTag: Bool = false
        var updatedTheTag: Bool = false
        var deltedTheTag: Bool = false
        
        let tagDict: [String: Any] = ["tag_id": 0, "tag_name": "TESTTAG"]
        let tag = Tag.init(with: tagDict)!
        
        self.handler.create(tag: tag) { (createdTag, error) in
            
            guard var createdTag = createdTag else {
                expectation.fulfill()
                return
            }
            
            createdTheTag = true
            
            createdTag.name = "ANOTHERNAME"
            
            self.handler.update(tag: createdTag) { (updatedTag, error) in
                
                guard let updatedTag = updatedTag else {
                    expectation.fulfill()
                    return
                }
                
                updatedTheTag = (updatedTag.name == "ANOTHERNAME")
                
                self.handler.delete(tag: updatedTag) { (delted, error) in
                    
                    deltedTheTag = delted
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheTag, "Created event successfull")
        XCTAssert(updatedTheTag, "Updated event successfull")
        XCTAssert(deltedTheTag, "Deleted event successfull")
    }
    
    // MARK: Manage Festivals Testing
    
    func testFetchFestivalsForTag() throws {
        
        let expectation = self.expectation(description: "Fetch festivals for tag")
        var testResult: Bool = false
        
        self.handler.festivals(for: 1, with: true) { (festivals, error) in
            
            testResult = (festivals?.count == 1)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch festivals for tag successfull")
    }
}
