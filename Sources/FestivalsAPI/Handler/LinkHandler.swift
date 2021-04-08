//
//  LinkHandler.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 18.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: Link Type

/// The LinkType enumeration defines a list of services a link can refer to.
public enum LinkType: Int, Codable, CaseIterable, Identifiable {
    /// An unknown service.
    case unknown                    = -1
    /// A website URL. Example: https://simonsapps.de/
    case websiteURL                 = 0
    /// An email address. Example: simon.cay.gaus@gmail.com
    case mail                       = 1
    /// A phone numer including the country code. Example: 0049406083579
    case phone                      = 2
    /// A youtube video referrer. Example: https://www.youtube.com/watch?v=**GpRd7i2Hyfk**
    case youtubeVideoRef            = 3
    /// A youtube user referrer. Example: https://www.youtube.com/user/**der8auer**
    case youtubeUserRef             = 4
    /// A youtube channel referrer. Example: https://www.youtube.com/channel/**UC7_gcs09iThXybpVgjHZ_7g**
    case youtubeChannelRef          = 5
    /// A youtube playlist referrer. Example: https://www.youtube.com/playlist?list=**PLsPUh22kYmNBVC9vvhnleNvgQOvkfjCrV**
    case youtubePlaylistRef         = 6
    /// A youtube music playlist referrer. Example:  https://music.youtube.com/playlist?list=**PL4fGSI1pDJn4X-OicSCOy-dChXWdTgziQ**
    case youtubeMusicPlaylistRef    = 7
    /// A soundcloud profile page referrer.  Example: https://soundcloud.com/**googy**
    case soundcloudProfileRef       = 8
    /// A bandcamp profile page URL. Example: https://alestorm.bandcamp.com/
    case bandcampProfileURL         = 9
    /// A bandcamp track URL. Example: https://joshuavirtue.bandcamp.com/track/fenti-face
    case bandcampTrackURL           = 10
    /// A Hearthis profile page referrer. Example: https://hearthis.at/**mixbuzz**
    case hearthisProfileRef         = 11
    /// A Hearthis enmbeded track referrer. Example: https://app.hearthis.at/embed/**3685286**
    case hearthisEmbededTrackRef    = 12
    /// A facebook profile page referrer. Example https://www.facebook.com/**Sufjan-Stevens-73949695413**
    case facebookProfileRef         = 13
    /// A instagram profile page referrer. Example: https://www.instagram.com/**thisistunng**
    case instagramProfileRef        = 14
    /// A spotify artist page referrer. Example: https://open.spotify.com/artist/**6KImCVD70vtIoJWnq6nGn3**
    case spotifyArtistRef           = 15
    /// A spotify album page referrer. Example: https://open.spotify.com/album/**1FZKIm3JVDCxTchXDo5jOV**
    case spotifyAlbumRef            = 16
    /// A spotify track referrer. Example: https://open.spotify.com/track/**1IF5UcqRO42D12vYwceOY6**
    case spotifyTrackRef            = 17
    /// An apple music store URL. Example: https://music.apple.com/de/artist/menomena/4384720
    case appleMusicStoreURL         = 18
    /// A shazam profile page referrer. Example: https://www.shazam.com/de/artist/**40827987**/die-antwoord
    case shazamProfileRef           = 19
    /// A shazam track referrer. Example: https://www.shazam.com/de/track/**55636080**/i-fink-u-freeky
    case shazamTrackRef             = 20
    /// A deezer profile page referrer. Example: https://www.deezer.com/de/artist/**2154**
    case deezerArtistRef            = 21
    /// A Twitter profile referrer. Example: https://twitter.com/**thisistunng**
    case twitterProfileRef          = 22
    /// A tiktook profile referer. Example: https://www.tiktok.com/**@rosalia**
    case tiktokProfileRef           = 23
    /// A Tripadvisor profile page URL. Example: https://www.tripadvisor.de/Restaurant_Review-g187323-d718338-Reviews-Schokoladen-Berlin.html).
    case tripadvisorURL              = 24
    
    public var id: Int {
        return rawValue
    }
    
    /// The localized name of the type.
    public var localizedName: String {
        switch self {
        case .unknown:
            return NSLocalizedString("Unknown", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .websiteURL:
            return NSLocalizedString("Website", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .mail:
            return NSLocalizedString("E-Mail", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .phone:
            return NSLocalizedString("Phone", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .youtubeVideoRef:
            return NSLocalizedString("Youtube Video", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .youtubeUserRef:
            return NSLocalizedString("Youtube User", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .youtubeChannelRef:
            return NSLocalizedString("Youtube Channel", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .youtubePlaylistRef:
            return NSLocalizedString("Youtube Playlist", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .youtubeMusicPlaylistRef:
            return NSLocalizedString("Youtube Music Playlist", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .soundcloudProfileRef:
            return NSLocalizedString("Soundcloud Profile", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .bandcampProfileURL:
            return NSLocalizedString("Bandcamp Profile", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .bandcampTrackURL:
            return NSLocalizedString("Bandcamp Track", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .hearthisProfileRef:
            return NSLocalizedString("Hearthis Profile", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .hearthisEmbededTrackRef:
            return NSLocalizedString("Hearthis Embeded Track", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .facebookProfileRef:
            return NSLocalizedString("Facebook Profile", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .instagramProfileRef:
            return NSLocalizedString("Instagram Profile", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .spotifyArtistRef:
            return NSLocalizedString("Spotify Artist", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .spotifyAlbumRef:
            return NSLocalizedString("Spotify Album", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .spotifyTrackRef:
            return NSLocalizedString("Spotify Track", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .appleMusicStoreURL:
            return NSLocalizedString("Apple Music Store URL", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .shazamProfileRef:
            return NSLocalizedString("Shazam Profile", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .shazamTrackRef:
            return NSLocalizedString("Shazam Track", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .deezerArtistRef:
            return NSLocalizedString("Deezer Artist", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .twitterProfileRef:
            return NSLocalizedString("Twitter Profile", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .tiktokProfileRef:
            return NSLocalizedString("TikTok Profile", bundle: .module, comment: "UI String - Identity string - Link Type")
        case .tripadvisorURL:
            return NSLocalizedString("Tripadvisor", bundle: .module, comment: "UI String - Identity string - Link Type")
        }
    }
}

// MARK: Link Struct

/// The `Link` struct represents a link as it is represented in the FestivalsAPI webservice.
public struct Link: Codable, Hashable, Identifiable {
    
    /// The identifier of the link. Every objectID is unique within all link instances.
    public var objectID: Int
    /// The version of the link. Although the value is actual a timestamp, it is not recommended to perform any calcualtions that depend on the value of the timstamp.
    public var version: String
    /// The referrer value.
    public var referrer: String
    /// The type of the link.
    public var service: LinkType
    
    /// Initializes a festival with the given data.
    /// - Parameter objectDict: The dict containing the festival values.
    public init?(with objectDict: Any?) {
        
        guard let objectDict        = objectDict as? [String: Any] else { return nil }
        guard let object_id         = objectDict["link_id"] as? Int else { return nil }
        guard let object_version    = objectDict["link_version"] as? String else { return nil }
        guard let object_referrer   = objectDict["link_url"] as? String else { return nil }
        guard let object_service    = objectDict["link_service"] as? Int else { return nil }
        guard let linkType          = LinkType(rawValue: object_service) else { return nil }
        self.objectID = object_id
        self.version = object_version
        self.referrer = object_referrer
        self.service = linkType
    }
    
    /// Creates links from an array of link dicts.
    /// - Parameter data: The dicts that contain the link values.
    /// - Returns: An array of links or nil.
    static func links(from data: [Any]) -> [Link]? {
        
        var links: [Link] = []
        for objectDict in data {
            guard let link = Link.init(with: objectDict) else { return nil }
            links.append(link)
        }
        return links
    }
    
    /// Creates a JSON representation of the link.
    /// - Returns: The JSON representation as data.
    public func JSON() -> Data {

        let dict: [String: Any] = ["link_id": self.objectID, "link_version": self.version, "link_url": self.referrer, "link_service": self.service.rawValue]
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
        hasher.combine(version)
    }
    
    public static func == (lhs: Link, rhs: Link) -> Bool {
        return lhs.objectID == rhs.objectID && lhs.version == rhs.version
    }
    
    public var id: Int {
        return objectID
    }
}

// MARK: LinkHandler Class

/// The LinkHandler class handles access to link objects, their associated objects and properties.
public class LinkHandler {
    
    /// The webservice to make requests to.
    var webservice: Webservice
    
    // MARK: Initialization
    
    /// Initilizes the handler object.
    /// - Parameter webservice: The webservice object for makeing calls to the FestivalsAPI web service.
    init(with webservice: Webservice) {
        self.webservice = webservice
    }
    
    // MARK: Fetch links
    
    ///  Fetches all available links.
    /// - Parameters:
    ///     - completion: The completion will be called when the loading is done.
    ///     - links: The fetched links.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func all(links completion: @escaping (_ links: [Link]?, _ error: Error?) -> (Void)) {
        
        self.links() { links, error in
            
            completion(links, error)
        }
    }
    
    ///  Fetches the links with the given IDs.
    /// - Parameters:
    ///     - objectIDs: Th IDs of the links you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - links: The fetched links.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func links(with objectIDs: [Int]? = nil, completion: @escaping (_ links: [Link]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetch("link", with: objectIDs) { (objects, error) -> (Void) in
            
            guard let objects = objects else {
                completion(nil, error)
                return
            }
            guard let links = Link.links(from: objects) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(links, nil)
        }
    }
    
    ///  Fetches the link with the given ID.
    /// - Parameters:
    ///     - objectID: Th ID of the link you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - link: The fetched link.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func link(with objectID: Int, completion: @escaping (_ link: Link?, _ error: Error?) -> (Void)) {
        
        self.links(with: [objectID]) { links, error in
            
            guard let links = links else {
                completion(nil, error)
                return
            }
            guard let link = links.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(link, nil)
        }
    }
    
    // MARK: Manage links
    
    /// Creates the given link and returns the created link.
    /// - Parameters:
    ///     - link: The link you want to create.
    ///     - completion: The result closure will be called when the request is done.
    ///     - link: The created link.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func create(link: Link, completion: @escaping (_ link: Link?, _ error: Error?) -> (Void)) {
        
        self.webservice.create("link", with: link.JSON()) { (object, error) -> (Void) in
        
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let createdLink = Link.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(createdLink, nil)
        }
    }
    
    /// Updates the given link and returns the updated link.
    /// - Parameters:
    ///     - link: The link you want to update.
    ///     - completion: The result closure will be called when the request is done.
    ///     - link: The updated link.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func update(link: Link, completion: @escaping (_ link: Link?, _ error: Error?) -> (Void)) {
        
        self.webservice.update("link", with: link.objectID, and: link.JSON()) { (object, error) -> (Void) in
        
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let updatedLink = Link.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(updatedLink, nil)
        }
    }
    
    /// Deletes the given link.
    /// - Parameters:
    ///     - link: The link you want to delete.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the deletion was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func delete(link: Link, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.delete("link", with: link.objectID) { (success, error) -> (Void) in
            
            completion(success, error)
        }
    }
}
