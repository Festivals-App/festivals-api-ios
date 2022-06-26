//
//  RequestCache.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 19.06.22.
//  Copyright © 2022 Simon Gaus. All rights reserved.
//

import Foundation

fileprivate let MINUTE = TimeInterval(60)
fileprivate let HOUR = TimeInterval(MINUTE*60)

final class RequestCache {
        
    private let dateProvider: () -> Date
    private let hotCacheLifetime: TimeInterval
    private let coldCacheLifetime: TimeInterval
    
    private let cache = NSCache<NSString, NSData>()
    
    init(dateProvider: @escaping () -> Date = Date.init,
         hotCacheLifetime: TimeInterval = MINUTE * 10,
         coldCacheLifetime: TimeInterval = HOUR * 24 * 7) {
        
        self.dateProvider = dateProvider
        self.hotCacheLifetime = hotCacheLifetime
        self.coldCacheLifetime = coldCacheLifetime
    }
    
    func fetch(_ cacheType: RequestCacheType, valueFor: String) -> Data? {
        
        if cacheType == .hot {
            
        }
        
        if cacheType == .cold {
            
        }
        
        return nil
    }
    
    func insert(_ value: Data, forKey key: String) {
        
    }
    
    func removeValue(forKey key: String) {
        
    }
}

extension RequestCache {
    
    enum RequestCacheType { case hot, cold }
}

extension RequestCache {
    
    subscript(key: String, cacheType: RequestCacheType = .hot) -> Data? {
        get { return self.fetch(cacheType, valueFor: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                self.removeValue(forKey: key)
                return
            }
            
            self.insert(value, forKey: key)
        }
    }
}
