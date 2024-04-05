//
//  IdentityAndTrust.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 03.04.24.
//  Copyright © 2024 Simon Gaus. All rights reserved.
//

import Foundation

/// The `CertificateProvider` is responsible for reading, parsing and providing certificates to be used in network communication.
public struct CertificateProvider {
    
    /// The identity used for resolving client certificate authentication challenges.
    public let identity: SecIdentity
    /// The trust object associated with this identity.
    public let trust: SecTrust
    /// The client certificates used to make network communication.
    public let certificates: [SecCertificate]
    /// The root CA certificate.
    public let CA: SecCertificate
    
    /// Initilizes the `CertificateProvider` object with the given certificate data, password and root CA cert data.
    /// - Parameters:
    ///   - certData: The data for a  PKCS #12 file containing a valid client certifcate and key.
    ///   - certPassword: The password for the given  PKCS #12 file.
    ///   - CAData: The data for the CA certificate that issued the given client certificate.
    public init?(certData: NSData, certPassword: String, rootCAData: NSData) {
        
        var items: CFArray?
        let securityStatus = SecPKCS12Import(certData, [kSecImportExportPassphrase as String : certPassword] as CFDictionary, &items)
        
        if securityStatus == errSecSuccess {
            
            guard let items = items else { return nil }
            let dict: AnyObject? = (items as Array).first
            
            if let certificateDict: Dictionary = dict as? Dictionary<String, AnyObject> {
                
                // get the identity
                let identityPointer: AnyObject? = certificateDict["identity"]
                let secIdentityRef: SecIdentity = identityPointer as! SecIdentity
                // get the trust
                let trustPointer: AnyObject? = certificateDict["trust"]
                guard let trustPointer else {
                    print("Failed to extract trust object from PKCS12 import.")
                    return nil
                }
                
                let trustRef: SecTrust = trustPointer as! SecTrust
                // get the certificate chain
                var certRef: SecCertificate?
                let status = SecIdentityCopyCertificate(secIdentityRef, &certRef)
                if status != errSecSuccess {
                    print("Failed to retrieve certificate from identity with OSStatus: \(status)")
                    return nil
                }
                guard let certRef else {
                    print("Failed to retrieve certificate from identity.")
                    return nil
                }
                guard var certificateArray = SecTrustCopyCertificateChain(trustRef) as? [SecCertificate] else {
                    print("Failed to copy certificate chain.")
                    return nil
                }
                certificateArray.append(certRef)
                guard let rootCACert = SecCertificateCreateWithData(nil, rootCAData as CFData) else {
                    print("Failed to read root CA certificate.")
                    return nil
                }
                
                self.identity = secIdentityRef
                self.trust = trustRef
                self.certificates = certificateArray
                self.CA = rootCACert
                return
            }
        }
        return nil
    }
}

/// The `TLSSessionDelegate` implements the interface needed to accept and validate server/client authentication challenges provided by an `URLSession` object.
public class TLSSessionDelegate : NSObject, URLSessionDelegate {
    
    /// The certificate provider to use for authentication challenges.
    private let certificateProvider: CertificateProvider

    /// Initializes the `TLSSessionDelegate` object with the given certificateProvider.
    /// - Parameter certificateProvider: The certificate provider to use.
    public init(certificateProvider: CertificateProvider) {
        self.certificateProvider = certificateProvider
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
    }
    
    /// Handling a server authentication challenges
    private func urlSession(_ session: URLSession,
                    didReceiveServerTrustChallenge challenge: URLAuthenticationChallenge,
                    with completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let trust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        guard shouldAllowHTTPSConnection(trust: trust, trustedCA: self.certificateProvider.CA) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        completionHandler(.useCredential, URLCredential(trust: trust))
    }
    
    /// Handling a client authentication challenges
    private func urlSession(_ session: URLSession,
                    didReceiveClientCertificateChallenge challenge: URLAuthenticationChallenge,
                    with completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(identity: self.certificateProvider.identity,
                                          certificates: self.certificateProvider.certificates as [AnyObject],
                                          persistence: URLCredential.Persistence.forSession)
        completionHandler(.useCredential, urlCredential)
    }

    /// Evaluates if the given server should be trusted.
    /// - See:  Found at https://developer.apple.com/forums/thread/703234
    /// - Parameters:
    ///   - trust: The trust object of the requesting server.
    ///   - trustedCA: The given
    /// - Returns: Returns `true` if the server should be trusted, otherwise `false`.
    private func shouldAllowHTTPSConnection(trust: SecTrust, trustedCA: SecCertificate) -> Bool {
        // set the policy for the trust
        var err = SecTrustSetPolicies(trust, SecPolicyCreateBasicX509())
        guard err == errSecSuccess else { return false }
        // set the root CA cert as anchor certificate for evaluation
        err = SecTrustSetAnchorCertificates(trust, [trustedCA] as NSArray)
        guard err == errSecSuccess else { return false }
        // only trust anchor certificates eg theroot CA cert
        err = SecTrustSetAnchorCertificatesOnly(trust, true)
        guard err == errSecSuccess else { return false }
        // evaluate the trust object
        var validationError: CFError? = nil
        let wasIssuedByRootCA = SecTrustEvaluateWithError(trust, &validationError)
        guard wasIssuedByRootCA else {
            print("Do not trust server with error: \(String(describing: validationError))")
            return false
        }
        return true
        /*
        guard let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let trustedLeaf = chain.first
        else {
            return false
        }
         C. Check the now-trusted leaf certificate
        found at https://developer.apple.com/forums/thread/703234
        */
    }
    
    /*
    /// Loads the certificate from the bundle  with the given name and file extension.
    /// - Parameters:
    ///   - resource: The name of the resource to load from the bundle.
    ///   - withExtension: The extension of the resource to load from the bundle.
    /// - Returns: The loaded certificate or `nil`
    func SecCertificateCreateFromBundle(resource: String, withExtension: String) -> SecCertificate? {
        
        guard let localCertPath = Bundle(for: Self.self).url(forResource: resource, withExtension: withExtension) else {
            print("Failed to load resource: '\(resource)' with extension: '\(withExtension)'")
            return nil
        }
        guard let localCertData = try? Data(contentsOf: localCertPath) else {
            print("Failed to load data from file at path '\(localCertPath)'")
            return nil
        }
        guard let localCertificate = SecCertificateCreateWithDERData(localCertData) else {
            print("Failed to parse certificate from local cert data at '\(localCertPath)'")
            return nil
        }
        return localCertificate
    }
    
    /// Creates a certificate from the given data in DER format.
    /// - Parameter data: The DER formated data to create the certificate from.
    /// - Returns: The certificate or nil
    private func SecCertificateCreateWithDERData(_ data: Data) -> SecCertificate? {
        
        if let remoteCertificate = SecCertificateCreateWithData(nil, data as CFData) {
            return remoteCertificate
        }
         #warning("Implement PEM to DER conversion")
        if  let certString = String(data: data as Data, encoding: .utf8) {
            print("certString: \(certString.trim())")
            if let convertedData = Data(base64Encoded: certString.trim(), options: .ignoreUnknownCharacters) {
                if let remoteCertificate = SecCertificateCreateWithData(nil, convertedData as CFData) {
                    return remoteCertificate
                } else { print("Failed to SecCertificateCreateWithData with converted data.") }
            } else { print("Failed to create base64Encoded data.") }
        } else { print("Failed to create certificate string from data.") }
         
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
        return nil
    }
    */
}
