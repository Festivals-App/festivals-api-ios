//
//  LinkHandlerTests.swift
//  FestivalsAPITests
//
//  Created by Simon Gaus on 02.05.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import XCTest

@testable import FestivalsAPI

class LinkHandlerTests: XCTestCase {
    
    var webservice: Webservice!
    var handler: LinkHandler!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard let urlValue = Bundle(for: Self.self).object(forInfoDictionaryKey: "FestivalsAPI_URL") as? String else { return }
        self.webservice = Webservice.init(baseURL: URL.init(string: urlValue)!, apiKey: "TEST_API_KEY_001", apiVersion: .v0_1, cached: false)
        self.handler = LinkHandler.init(with: self.webservice)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Fetch Links Testing
    
    func testFetchAllLinks() throws {
        
        let expectation = self.expectation(description: "Fetch all links")
        var testResult: Bool = false
        
        self.handler.all { (links, error) in
            testResult = (links != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch all links successfull")
    }
    
    func testFetchLinks() throws {
        
        let expectation = self.expectation(description: "Fetch some links")
        var testResult: Bool = false
        
        self.handler.links(with: [1,2]) { (links, error) in
            testResult = (links?.count == 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch some links successfull")
    }
    
    func testFetchLink() throws {
        
        let expectation = self.expectation(description: "Fetch a event")
        var testResult: Bool = false
        
        self.handler.link(with: 1) { (event, error) in
            testResult = (event != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetched an link successfull")
    }
    
    // MARK: Manage Links Testing
    
    func testLinkCreationAndDeletion() throws {
        
        let expectation = self.expectation(description: "Create and delete an event")
        var createdTheLink: Bool = false
        var deltedTheLink: Bool = false
        
        let linkDict: [String: Any] = ["link_id": 0, "link_version": "", "link_url": "https://www.test.de", "link_service": LinkType.websiteURL.rawValue]
        let link = Link.init(with: linkDict)!

        self.handler.create(link: link) { (createdLink, error) in
            
            guard let createdLink = createdLink else {
                expectation.fulfill()
                return
            }
            
            createdTheLink = true
            
            self.handler.delete(link: createdLink) { (delted, error) in
                
                deltedTheLink = delted
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheLink, "Created an link successfull")
        XCTAssert(deltedTheLink, "Deleted an link successfull")
    }
    
    func testLinkUpdating() throws {
        
        let expectation = self.expectation(description: "Update an event")
        var createdTheLink: Bool = false
        var updatedTheLink: Bool = false
        var deltedTheLink: Bool = false
        
        let linkDict: [String: Any] = ["link_id": 0, "link_version": "", "link_url": "https://www.test.de", "link_service": LinkType.websiteURL.rawValue]
        let link = Link.init(with: linkDict)!
        
        self.handler.create(link: link) { (createdLink, error) in
            
            guard var createdLink = createdLink else {
                expectation.fulfill()
                return
            }
            
            createdTheLink = true
            
            createdLink.referrer = "ANOTHERURL"
            createdLink.service = LinkType.unknown
            
            self.handler.update(link: createdLink) { (updatedLink, error) in
                
                guard let updatedLink = updatedLink else {
                    expectation.fulfill()
                    return
                }
                
                updatedTheLink = (updatedLink.referrer == "ANOTHERURL" && updatedLink.service == LinkType.unknown)
                
                self.handler.delete(link: updatedLink) { (delted, error) in
                    
                    deltedTheLink = delted
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheLink, "Created event successfull")
        XCTAssert(updatedTheLink, "Updated event successfull")
        XCTAssert(deltedTheLink, "Deleted event successfull")
    }
}
