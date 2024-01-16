//
//  ImageRefHandlerTests.swift
//  ImageRefusAPI-SwiftTests
//
//  Created by Simon Gaus on 02.05.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import XCTest

@testable import FestivalsAPI

class ImageRefHandlerTests: XCTestCase {
    
    var webservice: Webservice!
    var handler: ImageRefHandler!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard let urlValue = Bundle(for: Self.self).object(forInfoDictionaryKey: "FestivalsAPI_URL") as? String else { return }
        guard let localCAPath = Bundle(for: Self.self).url(forResource: "ca", withExtension: "der") else { return }
        guard let caData = try? Data(contentsOf: localCAPath) else { return }
        guard let localCertPath = Bundle(for: Self.self).url(forResource: "api-client", withExtension: "p12") else { return }
        guard let certData = try? Data(contentsOf: localCertPath) else { return }
        guard let clientAuth = IdentityAndTrust(certData: certData  as NSData, CAData: caData as NSData, certPassword: "we4711", apiKey: "TEST_API_KEY_001") else { return }
        self.webservice = Webservice(baseURL: URL(string: urlValue)!, clientAuth: clientAuth, apiVersion: .v0_1, cached: false)
        self.handler = ImageRefHandler.init(with: self.webservice)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Fetch Images Testing
    
    func testFetchAllImages() throws {
        
        let expectation = self.expectation(description: "Fetch all images")
        var testResult: Bool = false
        
        self.handler.all { (images, error) in
            testResult = (images != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch all images successfull")
    }
    
    func testFetchImages() throws {
        
        let expectation = self.expectation(description: "Fetch some images")
        var testResult: Bool = false
        
        self.handler.images(with: [1,2]) { (images, error) in
            testResult = (images?.count == 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetch some images successfull")
    }
    
    func testFetchImage() throws {
        
        let expectation = self.expectation(description: "Fetch a event")
        var testResult: Bool = false
        
        self.handler.image(with: 1) { (event, error) in
            testResult = (event != nil)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(testResult, "Fetched an image successfull")
    }
    
    // MARK: Manage Images Testing
    
    func testImageCreationAndDeletion() throws {
        
        let expectation = self.expectation(description: "Create and delete an event")
        var createdTheImageRef: Bool = false
        var deltedTheImageRef: Bool = false

        let imageDict: [String: Any] = ["image_id": 0, "image_hash": "a8f5f167f44f4964e6c998dee827110c", "image_comment": "TESTCOMMENT", "image_ref": "image.jpg"]
        let image = ImageRef.init(with: imageDict)!

        self.handler.create(image: image) { (createdImageRef, error) in
            
            guard let createdImageRef = createdImageRef else {
                expectation.fulfill()
                return
            }
            
            createdTheImageRef = true
            
            self.handler.delete(image: createdImageRef) { (delted, error) in
                
                deltedTheImageRef = delted
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheImageRef, "Created an image successfull")
        XCTAssert(deltedTheImageRef, "Deleted an image successfull")
    }
    
    func testImageUpdating() throws {
        
        let expectation = self.expectation(description: "Update an event")
        var createdTheImageRef: Bool = false
        var updatedTheImageRef: Bool = false
        var deltedTheImageRef: Bool = false
        
        let imageDict: [String: Any] = ["image_id": 0, "image_hash": "a8f5f167f44f4964e6c998dee827110c", "image_comment": "TESTCOMMENT", "image_ref": "image.jpg"]
        let image = ImageRef.init(with: imageDict)!
        
        self.handler.create(image: image) { (createdImageRef, error) in
            
            guard var createdImageRef = createdImageRef else {
                expectation.fulfill()
                return
            }
            
            createdTheImageRef = true
            
            createdImageRef.hash = "a3dcb4d229de6fde0db5686dee47145d"
            createdImageRef.comment = "ANOTHERCOMMENT"
            
            self.handler.update(image: createdImageRef) { (updatedImageRef, error) in
                
                guard let updatedImageRef = updatedImageRef else {
                    expectation.fulfill()
                    return
                }
                
                updatedTheImageRef = (updatedImageRef.hash == "a3dcb4d229de6fde0db5686dee47145d" && updatedImageRef.comment == "ANOTHERCOMMENT")
                
                self.handler.delete(image: updatedImageRef) { (delted, error) in
                    
                    deltedTheImageRef = delted
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssert(createdTheImageRef, "Created event successfull")
        XCTAssert(updatedTheImageRef, "Updated event successfull")
        XCTAssert(deltedTheImageRef, "Deleted event successfull")
    }
}
