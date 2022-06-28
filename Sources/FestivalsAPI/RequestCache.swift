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
    private let ioQueue: DispatchQueue
    
    init(dateProvider: @escaping () -> Date = Date.init,
         hotCacheLifetime: TimeInterval = MINUTE * 10,
         coldCacheLifetime: TimeInterval = HOUR * 24 * 7) {
        
        self.dateProvider = dateProvider
        self.hotCacheLifetime = hotCacheLifetime
        self.coldCacheLifetime = coldCacheLifetime
        let ioQueueName = "de.simonsserver.FestivalsAPI.RequestCache.ioQueue.\(UUID().uuidString)"
        self.ioQueue = DispatchQueue(label: ioQueueName)
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
        
        try? self.fileManager.createDirectory(at: self.fileManager.cacheDirectoryURL(), withIntermediateDirectories: true)
        let fileURL = self.fileManager.cacheFileURL(for: key)
        ioQueue.async {
            try? value.write(to: fileURL, options: .noFileProtection)
        }
    }
    
    func removeValue(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        let fileURL = self.fileManager.cacheFileURL(for: key)
        ioQueue.async {
            try? self.fileManager.removeItem(at: fileURL)
        }
    }
    
    func calculateDiskStorageSize(completion handler: @escaping ((Result<UInt, Error>) -> Void)) {
        
        let cacheDir = fileManager.cacheDirectoryURL()
        ioQueue.async {
            let size = cacheDir.sizeOnDisk() ?? UInt(0)
            DispatchQueue.main.async {
                return handler(.success(size))
            }
        }
    }
    
    func clearDiskCache(completion handler: (() -> Void)? = nil) {
        
        let cacheDir = fileManager.cacheDirectoryURL()
        let fileURLs = try? FileManager.default.contentsOfDirectory(at: cacheDir,
                                                                    includingPropertiesForKeys: nil,
                                                                    options: .skipsHiddenFiles)
        for fileURL in fileURLs ?? [] {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}

extension RequestCache {
    
    enum RequestCacheType { case hot, cold }
    
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
        return date > maxAge
    }
    
    func fileCreationDate() -> Date? {
        return (try? FileManager.default.attributesOfItem(atPath: path))?[.creationDate] as? Date
    }
    
    func sizeOnDisk() -> UInt? {
        return try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
            UInt((try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0)) + $0
        }
    }
    
}
