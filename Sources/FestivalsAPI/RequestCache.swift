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
    
    private let cache = NSCache<NSString, Entry>()
    
    private let fileManager = FileManager.default
    
    init(dateProvider: @escaping () -> Date = Date.init,
         hotCacheLifetime: TimeInterval = MINUTE * 10,
         coldCacheLifetime: TimeInterval = HOUR * 24 * 7) {
        
        self.dateProvider = dateProvider
        self.hotCacheLifetime = hotCacheLifetime
        self.coldCacheLifetime = coldCacheLifetime
    }
    
    func fetch(_ cacheType: RequestCacheType, valueFor key: String) -> Data? {
        
        if cacheType == .hot {
            guard let cachedEntry = cache.object(forKey: key as NSString) else { return nil }
            guard dateProvider() < cachedEntry.expirationDate else {
                removeValue(forKey: key)
                return nil
            }
            print("Return hot cached value for '\(key)'")
            return cachedEntry.value
        }
        
        if cacheType == .cold {
            
            let fileURL = fileManager.cacheFileURL(for: key)
            if fileURL.isExpired(using: dateProvider(), lifetime: coldCacheLifetime) {
                removeValue(forKey: key)
                return nil
            }
            guard let data = try? Data.init(contentsOf: fileURL) else {
                removeValue(forKey: key)
                return nil
            }
            print("Return cold cached value for '\(key)'")
            return data
        }
        
        return nil
    }
    
    func insert(_ value: Data, forKey key: String) {
        
        let hotExpiration = dateProvider().addingTimeInterval(hotCacheLifetime)
        let entry = Entry(key: key, value: value, expirationDate: hotExpiration)
        cache.setObject(entry, forKey: key as NSString)
        
        DispatchQueue.main.async {
            try? self.fileManager.createDirectory(at: self.fileManager.cacheDirectoryURL(), withIntermediateDirectories: true)
            let fileURL = self.fileManager.cacheFileURL(for: key)
            try? value.write(to: fileURL, options: .noFileProtection)
            print("did write cache file to \(fileURL)")
        }
    }
    
    func removeValue(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        DispatchQueue.main.async {
            let fileURL = self.fileManager.cacheFileURL(for: key)
            try? self.fileManager.removeItem(at: fileURL)
        }
    }
}

extension RequestCache {
    
    enum RequestCacheType { case hot, cold }
}

private extension RequestCache {
    
    final class Entry {
        
        let key: String
        let value: Data
        let expirationDate: Date
        
        init(key: String, value: Data, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
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

fileprivate extension FileManager {
    
    func cacheFileURL(for key: String) -> URL {
        let saveName = key.hash
        let fileURL = self.cacheDirectoryURL().appendingPathComponent("\(saveName)" + ".cache")
        return fileURL
    }
    
    func cacheDirectoryURL() -> URL {
        let folderURLs = self.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheFolderURL = folderURLs[0].appendingPathComponent("requestscache")
        return cacheFolderURL
    }
}

fileprivate extension URL {
    
    func isExpired(using date: Date, lifetime: TimeInterval) -> Bool {
        guard let created = self.fileCreationDate() else { return true }
        let maxAge = created.addingTimeInterval(lifetime)
        return date < maxAge
    }
    
    func fileCreationDate() -> Date? {
        return (try? FileManager.default.attributesOfItem(atPath: path))?[.creationDate] as? Date
    }
}
