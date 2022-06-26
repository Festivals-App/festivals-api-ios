//
//  RequestCache.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 19.06.22.
//  Copyright © 2022 Simon Gaus. All rights reserved.
//

import Foundation

final class RequestCache {
        
    private let dateProvider: () -> Date
    private let hotCacheLifetime: TimeInterval
    private let coldCacheLifetime: TimeInterval
    
    private let cache = NSCache<NSString, NSData>()
    
    init(dateProvider: @escaping () -> Date = Date.init,
         hotCacheLifetime: TimeInterval = 10 * 60, // 10 minutes
         coldCacheLifetime: TimeInterval = 60 * 60 * 24 * 7 // 7 days
    ) {
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
