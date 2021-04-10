//
//  ImageRefHandler.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 18.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: ImageRef Struct

/// The `ImageRef` struct represents an image reference as it is represented in the FestivalsAPI webservice.
public struct ImageRef: Codable, Hashable, Identifiable {
    
    /// The identifier of the image reference. Every objectID is unique within all image reference instances.
    public var objectID: Int
    /// The hash of the referenced image.
    public var hash: String
    /// The comment of the image reference. This value is ment to contain information about copyright, author and lizense of the image.
    public var comment: String
    /// The reference to the image.
    public var referrerURL: URL
    
    /// Initializes an image reference with the given data.
    /// - Parameter objectDict: The dict containing the image reference values.
    public init?(with objectDict: Any?) {
       
        guard let objectDict        = objectDict as? [String: Any] else { return nil }
        guard let object_id         = objectDict["image_id"] as? Int else { return nil }
        guard let object_hash       = objectDict["image_hash"] as? String else { return nil }
        guard let object_comment    = objectDict["image_comment"] as? String else { return nil }
        guard let object_ref_string = objectDict["image_ref"] as? String else { return nil }
        guard let urlFromString     = URL.init(string: object_ref_string) else { return nil }
        
        self.init(objectID: object_id, hash: object_hash, comment: object_comment, referrerURL: urlFromString)
    }
    
    /// Initializes an image with the given values.
    /// - Parameters:
    ///   - objectID: The objectID of the image. *Only applicable to images that come from the webservice. Locally created images do not have a distinct objectID.*
    ///   - hash: The version of the image. *Only applicable to images that come from the webservice. Locally created images do not have a distinct version.*
    ///   - comment: The comment of the image.
    ///   - referrerURL: The referrerURL of the image.
    public init(objectID: Int = 0, hash: String = "<unhashed>", comment: String = "", referrerURL: URL) {
        self.objectID = objectID
        self.hash = hash
        self.comment = comment
        self.referrerURL = referrerURL
    }
    
    /// Creates image refs from an array of image ref dicts.
    /// - Parameter data: The dicts that contain the image ref values.
    /// - Returns: An array of image refs or nil.
    static func imageRefs(from data: [Any]) -> [ImageRef]? {
        
        var imageRefs: [ImageRef] = []
        for objectDict in data {
            guard let imageRef = ImageRef.init(with: objectDict) else { return nil }
            imageRefs.append(imageRef)
        }
        return imageRefs
    }
    
    /// Creates a JSON representation of the image reference.
    /// - Returns: The JSON representation as data.
    public func JSON() -> Data {
        
        let dict: [String: Any] = ["image_id": self.objectID, "image_hash": self.hash, "image_comment": self.comment, "image_ref": self.referrerURL.absoluteString]
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
        hasher.combine(hashValue)
    }
    
    public static func == (lhs: ImageRef, rhs: ImageRef) -> Bool {
        return lhs.objectID == rhs.objectID && lhs.hashValue == rhs.hashValue
    }
    
    public var id: Int {
        return objectID
    }
}

// MARK: ImageRefHandler Class

/// The ImageRefHandler class handles access to image objects, their associated objects and properties.
public class ImageRefHandler {
    
    /// The webservice to make requests to.
    var webservice: Webservice
    
    /// Initilizes the handler object.
    /// - Parameter webservice: The webservice object for makeing calls to the FestivalsAPI web service.
    init(with webservice: Webservice) {
        self.webservice = webservice
    }
    
    // MARK: Fetch images
    
    ///  Fetches all available images.
    /// - Parameters:
    ///     - completion: The completion will be called when the loading is done.
    ///     - images: The fetched images.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func all(images completion: @escaping (_ images: [ImageRef]?, _ error: Error?) -> (Void)) {
        
        self.images() { festivals, error in
            
            completion(festivals, error)
        }
    }
    
    ///  Fetches the images with the given IDs.
    /// - Parameters:
    ///     - objectIDs: Th IDs of the images you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - images: The fetched images.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func images(with objectIDs: [Int]? = nil, completion: @escaping (_ images: [ImageRef]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetch("image", with: objectIDs) { (objects, err) in
            
            guard let objects = objects else {
                completion(nil, err)
                return
            }
            guard let images = ImageRef.imageRefs(from: objects) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(images, nil)
        }
    }
    
    ///  Fetches the image with the given ID.
    /// - Parameters:
    ///     - objectID: Th ID of the image you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - image: The fetched image.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func image(with objectID: Int, completion: @escaping (_ image: ImageRef?, _ error: Error?) -> (Void)) {
        
        self.images(with: [objectID]) { (imageRefs, error) in
            
            guard let imageRefs = imageRefs else {
                completion(nil, error)
                return
            }
            guard let imageRef = imageRefs.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(imageRef, nil)
        }
    }
    
    // MARK: Manage images
    
    /// Creates the given image and returns the created image.
    /// - Parameters:
    ///     - image: The image you want to create.
    ///     - completion: The result closure will be called when the request is done.
    ///     - image: The created image.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func create(image: ImageRef, completion: @escaping (_ image: ImageRef?, _ error: Error?) -> (Void)) {
        
        self.webservice.create("image", with: image.JSON()) { (object, error) in
        
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let createdImageRef = ImageRef.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(createdImageRef, nil)
        }
    }
    
    /// Updates the given image and returns the updated image.
    /// - Parameters:
    ///     - image: The image you want to update.
    ///     - completion: The result closure will be called when the request is done.
    ///     - image: The updated image.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func update(image: ImageRef, completion: @escaping (_ image: ImageRef?, _ error: Error?) -> (Void)) {
        
        self.webservice.update("image", with: image.objectID, and: image.JSON()) { (object, error) in
        
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let updatedImageRef = ImageRef.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(updatedImageRef, nil)
        }
    }
    
    /// Deletes the given image.
    /// - Parameters:
    ///     - image: The image you want to delete.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the deletion was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func delete(image: ImageRef, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.delete("image", with: image.objectID) { (success, error) in
            
            completion(success, error)
        }
    }
}
