//
//  TagHandler.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 18.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: Tag Struct

/// The `Tag` struct represents a tag as it is represented in the FestivalsAPI webservice.
public struct Tag: Codable, Hashable, Identifiable {
    
    /// The identifier of the tag. Every objectID is unique within all tag instances.
    public var objectID: Int
    /// The name of the tag. The name must not be unique but it is highly recommended.
    public var name: String
    
    /// Initializes a tag with the given data.
    /// - Parameter objectDict: The dict containing the tag values.
    public init?(with objectDict: Any?) {
        
        guard let objectDict        = objectDict as? [String: Any] else { return nil }
        guard let object_id         = objectDict["tag_id"] as? Int else { return nil }
        guard let object_name       = objectDict["tag_name"] as? String else { return nil }
        
        self.init(objectID: object_id, name: object_name)
    }
    
    /// Initializes a tag with the given values.
    /// - Parameters:
    ///   - objectID: The objectID of the tag. *Only applicable to tags that come from the webservice. Locally created tags do not have a distinct objectID.*
    ///   - name: The name of the tag.
    public init(objectID: Int = 0, name: String) {
        self.objectID = objectID
        self.name = name
    }
    
    /// Creates tags from an array of tag dicts.
    /// - Parameter data: The dicts that contain the tag values.
    /// - Returns: An array of tags or nil.
    static func tags(from data: [Any]) -> [Tag]? {
        
        var tags: [Tag] = []
        for objectDict in data {
            guard let tag = Tag.init(with: objectDict) else { return nil }
            tags.append(tag)
        }
        return tags
    }
    
    /// Creates a JSON representation of the tag.
    /// - Returns: The JSON representation as data.
    public func JSON() -> Data {
        
        let dict: [String: Any] = ["tag_id": self.objectID, "tag_name": self.name]
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
    }
    
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.objectID == rhs.objectID
    }
    
    public var id: Int {
        return objectID
    }
}

// MARK: TagHandler Class

/// The TagHandler class handles access to tag objects, their associated objects and properties.
public class TagHandler {
    
    /// The webservice to make requests to.
    var webservice: Webservice
    
    /// Initilizes the handler object.
    /// - Parameter webservice: The webservice object for makeing calls to the FestivalsAPI web service.
    init(with webservice: Webservice) {
        self.webservice = webservice
    }
    
    // MARK: Fetch tags
    
    ///  Fetches all available tags.
    /// - Parameters:
    ///     - completion: The completion will be called when the loading is done.
    ///     - tags: The fetched tags.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func all(tags completion: @escaping (_ tags: [Tag]?, _ error: Error?) -> (Void)) {
        
        self.tags() { tags, error in
            
            completion(tags, error)
        }
    }
    
    ///  Fetches the tags with the given IDs.
    /// - Parameters:
    ///     - objectIDs: Th IDs of the tags you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - tags: The fetched tags.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func tags(with objectIDs: [Int]? = nil, completion: @escaping (_ tags: [Tag]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetch("tag", with: objectIDs) { (objects, err) in
            
            guard let objects = objects else {
                completion(nil, err)
                return
            }
            guard let tags = Tag.tags(from: objects) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(tags, nil)
        }
    }
    
    ///  Fetches the tag with the given ID.
    /// - Parameters:
    ///     - objectID: Th ID of the tag you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - tag: The fetched tag.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func tag(with objectID: Int, completion: @escaping (_ tag: Tag?, _ error: Error?) -> (Void)) {
        
        self.tags(with: [objectID]) { (tags, error) in
            
            guard let tags = tags else {
                completion(nil, error)
                return
            }
            guard let tag = tags.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(tag, nil)
        }
    }
    
    // MARK: Manage tags
    
    /// Creates the given tag and returns the created tag.
    /// - Parameters:
    ///     - tag: The tag you want to create.
    ///     - completion: The result closure will be called when the request is done.
    ///     - tag: The created tag.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func create(tag: Tag, completion: @escaping (_ tag: Tag?, _ error: Error?) -> (Void)) {
        
        self.webservice.create("tag", with: tag.JSON()) { (object, error) in
        
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let createdTag = Tag.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(createdTag, nil)
        }
    }
    
    /// Updates the given tag and returns the updated tag.
    /// - Parameters:
    ///     - tag: The tag you want to update.
    ///     - completion: The result closure will be called when the request is done.
    ///     - tag: The updated tag.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func update(tag: Tag, completion: @escaping (_ tag: Tag?, _ error: Error?) -> (Void)) {
        
        self.webservice.update("tag", with: tag.objectID, and: tag.JSON()) { (object, error) in
        
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let updatedTag = Tag.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(updatedTag, nil)
        }
    }
    
    /// Deletes the given tag.
    /// - Parameters:
    ///     - tag: The tag you want to delete.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the deletion was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func delete(tag: Tag, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.delete("tag", with: tag.objectID) { (success, error) in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage festivals
    
    /// Fetches the festivals for the given tag.
    /// - Parameters:
    ///     - tagID: The ID of the tag you want to fetch the festivals for.
    ///     - includes: Boolean value indicating if you want the festivals to include their related objects.
    ///     - completion: The result closure will be called when the request is done.
    ///     - events: The fetched festivals.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func festivals(for tagID: Int, with includes: Bool, completion: @escaping (_ festivals: [Festival]?, _ error: Error?) -> (Void)) {
        
        let includeVals = ["image"]
        self.webservice.fetchResource("festivals", for: "tag", with: tagID, including: includeVals) { (resources, error) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let festivals = Festival.festivals(from: resources) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(festivals, nil)
        }
    }
}
