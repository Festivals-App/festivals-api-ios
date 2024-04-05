//
//  ClientAuth.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 15.01.24.
//  Copyright © 2024 Simon Gaus. All rights reserved.
//

import Foundation

public struct ClientAuth {
    
    public let apiKey: String
    public let certificates: CertificateProvider
    
    public init(apiKey: String, certificates: CertificateProvider) {
        self.apiKey = apiKey
        self.certificates = certificates
    }
}
