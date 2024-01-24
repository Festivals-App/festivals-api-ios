//
//  ClientAuth.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 15.01.24.
//  Copyright © 2024 Simon Gaus. All rights reserved.
//

import Foundation

public struct IdentityAndTrust {
    
    public let identityRef: SecIdentity
    public let trust: SecTrust
    public let certificates: [SecCertificate]
    public let apiKey: String
    public let CA: SecCertificate

    public init?(certData: NSData, CAData: NSData, certPassword: String, apiKey: String) {
        
        var securityStatus: OSStatus = errSecSuccess
        var items: CFArray?
        let certOptions: Dictionary = [kSecImportExportPassphrase as String : certPassword]
        securityStatus = SecPKCS12Import(certData, certOptions as CFDictionary, &items)
        if securityStatus == errSecSuccess {
            let certificateItems: CFArray = items! as CFArray
            let certItemsArray: Array = certificateItems as Array
            let dict: AnyObject? = certItemsArray.first
            
            if let certificateDict: Dictionary = dict as? Dictionary<String, AnyObject> {
                
                // get the identity
                let identityPointer: AnyObject? = certificateDict["identity"]
                let secIdentityRef: SecIdentity = identityPointer as! SecIdentity
                
                // get the trust
                let trustPointer: AnyObject? = certificateDict["trust"]
                let trustRef: SecTrust = trustPointer as! SecTrust
                
                // get the certificate chain
                var certRef: SecCertificate? // <- write on
                SecIdentityCopyCertificate(secIdentityRef, &certRef)
                guard var certificateArray = SecTrustCopyCertificateChain(trustRef) as? [SecCertificate] else {
                    print("Failed to copy certificate chain.")
                    return nil
                }
                certificateArray.append(certRef! as SecCertificate)
                /*
                let count = SecTrustGetCertificateCount(trustRef)
                if count > 1 {
                    for i in 1..<count {
                        if let cert = SecTrustGetCertificateAtIndex(trustRef, i) {
                            certificateArray.append(cert)
                        }
                    }
                }
                */
                
                guard let remoteCertificate = SecCertificateCreateWithData(nil, CAData as CFData) else {
                    print("Failed to read CA certificate.")
                    return nil
                }
                
                self.identityRef = secIdentityRef
                self.trust = trustRef
                self.certificates = certificateArray
                self.CA = remoteCertificate
                self.apiKey = apiKey
                return
            }
        }
        return nil
    }
}

public class SessionDelegate : NSObject, URLSessionDelegate {
    
    private let clientAuth: IdentityAndTrust

    init(clientAuth: IdentityAndTrust) {
        self.clientAuth = clientAuth
    }
    
    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            urlSession(session, didReceiveServerTrustChallenge: challenge, with: completionHandler)
            return
        }
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            urlSession(session, didReceiveClientCertificateChallenge: challenge, with: completionHandler)
            return
        }
        
        completionHandler(.performDefaultHandling, nil)
        return
    }
    
    func urlSession(_ session: URLSession,
                    didReceiveClientCertificateChallenge challenge: URLAuthenticationChallenge,
                    with completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let urlCredential = URLCredential(identity: clientAuth.identityRef,
                                          certificates: clientAuth.certificates as [AnyObject],
                                          persistence: URLCredential.Persistence.forSession)
        completionHandler(.useCredential, urlCredential)
    }
    
    func urlSession(_ session: URLSession,
                    didReceiveServerTrustChallenge challenge: URLAuthenticationChallenge,
                    with completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        
        
        let trust = challenge.protectionSpace.serverTrust!
        guard shouldAllowHTTPSConnection(trust: trust, trustedCA: clientAuth.CA) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        completionHandler(.useCredential, URLCredential(trust: trust))
        return
    }
    
    // found at https://developer.apple.com/forums/thread/703234
    func shouldAllowHTTPSConnection(trust: SecTrust, trustedCA: SecCertificate) -> Bool {
        var err = SecTrustSetPolicies(trust, SecPolicyCreateBasicX509())
        guard err == errSecSuccess else { return false }
        err = SecTrustSetAnchorCertificates(trust, [trustedCA] as NSArray)
        guard err == errSecSuccess else { return false }
        err = SecTrustSetAnchorCertificatesOnly(trust, true)
        guard err == errSecSuccess else { return false }
        let wasIssuedByOurCA = SecTrustEvaluateWithError(trust, nil)
        guard wasIssuedByOurCA else { return false }
        guard
            let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
            let trustedLeaf = chain.first
        else {
            return false
        }
        // C. Check the now-trusted leaf certificate
        return true
    }
    
    func SecCertificateCreateFrom(resource: String, withExtension: String) -> SecCertificate? {
        
        guard let localCertPath = Bundle(for: Self.self).url(forResource: resource, withExtension: withExtension) else {
            print("Failed to load Bundle.(for: Self.self).url(forResource: '\(resource)', withExtension: '\(withExtension)')")
            return nil
        }
        
        guard let localCertData = try? Data(contentsOf: localCertPath) else {
            print("Failed to Data(contentsOf: localCertPath)")
            return nil
        }
        
        guard let localCertificate = SecCertificateCreateWithPEMorDERData(localCertData) else {
            print("Failed to SecCertificateCreateWithPEMorDERData from localCertData")
            return nil
        }
        
        return localCertificate
    }
    
    
    func SecCertificateCreateWithPEMorDERData(_ data: Data) -> SecCertificate? {
        
        if let remoteCertificate = SecCertificateCreateWithData(nil, data as CFData) {
            return remoteCertificate
        }
        
        /*
         #warning("Implement PEM to DER conversion")
        if  let certString = String(data: data as Data, encoding: .utf8) {
            print("certString: \(certString.trim())")
            if let convertedData = Data(base64Encoded: certString.trim(), options: .ignoreUnknownCharacters) {
                
        
                
                
                if let remoteCertificate = SecCertificateCreateWithData(nil, convertedData as CFData) {
                    return remoteCertificate
                } else { print("Failed to SecCertificateCreateWithData with converted data.") }
            } else { print("Failed to create base64Encoded data.") }
        } else { print("Failed to create certificate string from data.") }
        */
        return nil
    }
}

extension String {
    func trim() -> String {
          return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension SecCertificate {
    func data() -> Data? {
        return CFBridgingRetain(SecCertificateCopyData(self)) as? Data
    }
}
