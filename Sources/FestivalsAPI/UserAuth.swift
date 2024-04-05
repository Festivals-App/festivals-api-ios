//
//  UserAuth.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 30.03.24.
//  Copyright © 2024 Simon Gaus. All rights reserved.
//

import Foundation

public struct UserAuth {
    
    public let jwt: String
    public let apiKey: String
    public let certificates: CertificateProvider
    
    public init(jwt: String, apiKey: String, certificates: CertificateProvider) {
        self.jwt = jwt
        self.apiKey = apiKey
        self.certificates = certificates
    }
}


