//
//  XCTestCase+Common.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 29.05.25.
//

import XCTest

extension XCTestCase {
    
    enum HandlerTestsError: Error, Equatable {
        case setUpFailed(reason: String)
    }
    
    func loadCertificates() throws -> (NSData, NSData) {
        
        guard let caName = ProcessInfo.processInfo.environment["CA_NAME"] else {
            throw HandlerTestsError.setUpFailed(reason: "No CA_NAME environment variable set")
        }
        guard let clientCertName = ProcessInfo.processInfo.environment["CLIENT_CERT_NAME"] else {
            throw HandlerTestsError.setUpFailed(reason: "No CLIENT_CERT_NAME environment variable set")
        }
        guard let localCAPath = Bundle.module.url(forResource: caName, withExtension: "der") else {
            throw HandlerTestsError.setUpFailed(reason: "Missing ca certificate in bundle")
        }
        guard let caData = try? Data(contentsOf: localCAPath) else {
            throw HandlerTestsError.setUpFailed(reason: "Failed to load ca certificate from bundle")
        }
        guard let localCertPath = Bundle.module.url(forResource: clientCertName, withExtension: "p12") else {
            throw HandlerTestsError.setUpFailed(reason: "Missing client certificate in bundle")
        }
        guard let certData = try? Data(contentsOf: localCertPath) else {
            throw HandlerTestsError.setUpFailed(reason: "Failed to load client certificate from bundle")
        }
        return (caData as NSData, certData as NSData)
    }
}
