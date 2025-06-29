//
//  ArtistHandler.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 18.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: Artist Struct

/// The `Artist` struct represents an artist as it is represented in the FestivalsAPI webservice.
public class Artist: ObservableObject, Hashable, Identifiable {
    
    /// The identifier of the artist. Every objectID is unique within all artist instances.
    public var objectID: Int
    /// The version of the artist. Although the value is actual a timestamp, it is not recommended to perform any calcualtions that depend on the value of the timstamp.
    public var version: String
    /// The name of the artist. The name must not be unique but it is highly recommended.
    public var name: String
    /// The description of the artist.
    public var description: String
    
    /// The image associated with the artist.
    @Published public var image: ImageRef?
    /// The links associated with the artist.
    @Published public var links: [Link]?
    /// The tags associated with the artist.
    @Published public var tags: [Tag]?
    
    /// Initializes an artist with the given data.
    /// - Parameter objectDict: The dict containing the artist values.
    public convenience init?(with objectDict: Any?) {
        
        guard let objectDict            = objectDict as? [String: Any] else { return nil }
        guard let object_id             = objectDict["artist_id"] as? Int else { return nil }
        guard let object_version        = objectDict["artist_version"] as? String else { return nil }
        guard let object_name           = objectDict["artist_name"] as? String else { return nil }
        guard let object_description    = objectDict["artist_description"] as? String else { return nil }
        
        var object_image :ImageRef? = nil
        var object_links :[Link]? = nil
        var object_tags  :[Tag]? = nil
        
        if let includes = objectDict["include"] as? [String: Any] {
            
            if let images = includes["image"] as? [Any] {
                if let imageDict = images.first {
                    object_image = ImageRef.init(with: imageDict)
                }
            }
            if let links = includes["link"] as? [Any] {
                object_links = Link.links(from: links)
            }
            if let tags = includes["tag"] as? [Any] {
                object_tags = Tag.tags(from: tags)
            }
        }
        
        self.init(objectID: object_id, version: object_version, name: object_name, description: object_description, image: object_image, links: object_links, tags: object_tags)
    }
    
    /// Initializes an artist with the given values.
    /// - Parameters:
    ///   - objectID: The objectID of the artist. *Only applicable to artists that come from the webservice. Locally created artists do not have a distinct objectID.*
    ///   - version: The version of the artist. *Only applicable to artists that come from the webservice. Locally created artists do not have a distinct version.*
    ///   - name: The name of the artist.
    ///   - description: The description of the artist.
    ///   - image: The image of the artist.
    ///   - links: The links of the artist.
    ///   - tags: The tags of the artist.
    public init(objectID: Int = 0, version: String = "<unversioned>", name: String, description: String, image: ImageRef? = nil, links: [Link]? = nil, tags: [Tag]? = nil) {
        
        self.objectID = objectID
        self.version = version
        self.name = name
        self.description = description
        
        self.image = image
        self.links = links
        self.tags = tags
    }
    
    /// Creates artists from an array of artist dicts.
    /// - Parameter data: The dicts that contain the artist values.
    /// - Returns: An array of artists or nil.
    static func artists(from data: [Any]) -> [Artist]? {
        
        var artists: [Artist] = []
        for objectDict in data {
            guard let artist = Artist.init(with: objectDict) else { return nil }
            artists.append(artist)
        }
        return artists
    }
    
    /// Creates a JSON representation of the artist.
    /// - Returns: The JSON representation as data.
    public func JSON() -> Data {

        let dict: [String: Any] = ["artist_id": self.objectID, "artist_version": self.version, "artist_name": self.name, "artist_description": self.description]
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
        hasher.combine(version)
    }
    
    public static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.objectID == rhs.objectID && lhs.version == rhs.version
    }
    
    public var id: Int {
        return objectID
    }
}

// MARK: ArtistHandler Class

/// The ArtistHandler class handles access to artist objects, their associated objects and properties.
public class ArtistHandler {
    
    /// The webservice to make requests to.
    private let webservice: Webservice
    
    /// Initilizes the handler object.
    /// - Parameter webservice: The webservice object for makeing calls to the FestivalsAPI web service.
    init(with webservice: Webservice) {
        self.webservice = webservice
    }
    
    // MARK: Fetching artists
    
    ///  Fetches all available artists.
    /// - Parameters:
    ///     - completion: The completion will be called when the loading is done.
    ///     - artists: The fetched artists.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func all(artists completion: @escaping (_ artists: [Artist]?, _ error: Error?) -> (Void)) {
        
        self.artists() { artists, error in
            
            completion(artists, error)
        }
    }
    
    public func allSimple(artists completion: @escaping (_ artists: [Artist]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetch("artist", with: nil, including: nil) { (objects, error) in
            
            guard let objects = objects else {
                completion(nil, error)
                return
            }
            guard let artists = Artist.artists(from: objects) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(artists, nil)
        }
    }
    
    ///  Fetches the artists with the given IDs.
    /// - Parameters:
    ///     - objectIDs: Th IDs of the artists you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - artists: The fetched artists.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func artists(with objectIDs: [Int]? = nil, completion: @escaping (_ artists: [Artist]?, _ error: Error?) -> (Void)) {
 
        self.webservice.fetch("artist", with: objectIDs, including: ["image", "link", "tag"]) { (objects, error) in
            
            guard let objects = objects else {
                completion(nil, error)
                return
            }
            guard let artists = Artist.artists(from: objects) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(artists, nil)
        }
    }
    
    ///  Fetches the artist with the given ID.
    /// - Parameters:
    ///     - objectID: Th ID of the artist you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - artist: The fetched artist.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func artist(with objectID: Int, completion: @escaping (_ artist: Artist?, _ error: Error?) -> (Void)) {
        
        self.artists(with: [objectID]) { artists, error in
            
            guard let artists = artists else {
                completion(nil, error)
                return
            }
            guard let artist = artists.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(artist, nil)
        }
    }
    
    // MARK: Manage artists
    
    /// Creates the given artist and returns the created artist.
    /// - Parameters:
    ///     - artist: The artist you want to create.
    ///     - completion: The result closure will be called when the request is done.
    ///     - artist: The created artist.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func create(artist: Artist, completion: @escaping (_ artist: Artist?, _ error: Error?) -> (Void)) {
        
        self.webservice.create("artist", with: artist.JSON()) { (object, error) in
        
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let createdArtist = Artist.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(createdArtist, nil)
        }
    }
    
    /// Updates the given artist and returns the updated artist.
    /// - Parameters:
    ///     - artist: The artist you want to update.
    ///     - completion: The result closure will be called when the request is done.
    ///     - artist: The updated artist.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func update(artist: Artist, completion: @escaping (_ artist: Artist?, _ error: Error?) -> (Void)) {
        
        self.webservice.update("artist", with: artist.objectID, and: artist.JSON()) { (object, error) in
        
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let updatedArtist = Artist.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(updatedArtist, nil)
        }
    }
    
    /// Deletes the given artist.
    /// - Parameters:
    ///     - artist: The artist you want to delete.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the deletion was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func delete(artist: Artist, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.delete("artist", with: artist.objectID) { (success, error) in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage links
    
    /// Fetches the links for the given artist.
    /// - Parameters:
    ///     - artistID: The ID of the artist you want to fetch the links for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - links: The fetched links.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func links(for artistID: Int, completion: @escaping (_ links: [Link]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("links", for: "artist", with: artistID) { (resources, error) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let links = Link.links(from: resources) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(links, nil)
        }
    }
    
    /// Associates the link with the given artist.
    /// - Parameters:
    ///     - linkID: The ID of the link you want to set.
    ///     - artistID: The ID of the artist you want to set the link for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(linkID: Int, for artistID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("links", with: linkID, for: "artist", with: artistID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the link with the given ID and the artist with the given ID.
    /// - Parameters:
    ///     - linkID: The ID of the link for which you want to remove the association.
    ///     - artistID: The ID of the artist for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func remove(linkID: Int, for artistID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("links", with: linkID, for: "artist", with: artistID) { success, error in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage tags
    
    /// Fetches the tags for the given artist.
    /// - Parameters:
    ///     - artistID: The ID of the artist you want to fetch the tags for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - links: The fetched tags.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func tags(for artistID: Int, completion: @escaping (_ tags: [Tag]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("tags", for: "artist", with: artistID) { (resources, error) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let tags = Tag.tags(from: resources) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(tags, nil)
        }
    }
    
    /// Associates the tag with the given artist.
    /// - Parameters:
    ///     - tagID: The ID of the tag you want to set.
    ///     - artistID: The ID of the artist you want to set the tag for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(tagID: Int, for artistID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("tags", with: tagID, for: "artist", with: artistID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the tag with the given ID and the artist with the given ID.
    /// - Parameters:
    ///     - tagID: The ID of the tag for which you want to remove the association.
    ///     - artistID: The ID of the artist for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func remove(tagID: Int, for artistID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("tags", with: tagID, for: "artist", with: artistID) { success, error in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage the image
    
    /// Fetches the image for the given artist.
    /// - Parameters:
    ///     - artistID: The ID of the artist you want to fetch the image for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - links: The fetched image.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func image(for artistID: Int, completion: @escaping (_ image: ImageRef?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("image", for: "artist", with: artistID) { (resources, error) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let images = ImageRef.imageRefs(from: resources) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            guard let image = images.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(image, nil)
        }
    }
    
    /// Associates the image with the given artist.
    /// - Parameters:
    ///     - tagID: The ID of the image you want to set.
    ///     - artistID: The ID of the artist you want to set the image for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(imageID: Int, for artistID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("image", with: imageID, for: "artist", with: artistID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the image with the given ID and the artist with the given ID.
    /// - Parameters:
    ///     - tagID: The ID of the image for which you want to remove the association.
    ///     - artistID: The ID of the artist for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func remove(imageID: Int, for artistID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("image", with: imageID, for: "artist", with: artistID) { success, error in
            
            completion(success, error)
        }
    }
}
