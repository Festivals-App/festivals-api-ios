//
//  LocationHandler.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 18.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: Location Struct

/// The `Location` struct represents a location as it is represented in the FestivalsAPI webservice.
public class Location: ObservableObject, Hashable, Identifiable {
    
    /// The identifier of the location. Every objectID is unique within all location instances.
    public var objectID: Int
    /// The version of the location. Although the value is actual a timestamp, it is not recommended to perform any calcualtions that depend on the value of the timstamp.
    public var version: String
    /// The name of the location. The name must not be unique but it is highly recommended.
    public var name: String
    /// The description of the artist.
    public var description: String
    /// Boolean value indicating if the location is accessible.
    public var accessible: Bool
    /// Boolean value indicating if the location is open air.
    public var openair: Bool
    
    /// The image associated with the location.
    @Published public var image: ImageRef?
    /// The links associated with the location.
    @Published public var links: [Link]?
    /// The place associated with the location.
    @Published public var place: Place?
    
    /// Initializes a location with the given data.
    /// - Parameter objectDict: The dict containing the location values.
    public convenience init?(with objectDict: Any?) {
        
        guard let objectDict            = objectDict as? [String: Any] else { return nil }
        guard let object_id             = objectDict["location_id"] as? Int else { return nil }
        guard let object_version        = objectDict["location_version"] as? String else { return nil }
        guard let object_name           = objectDict["location_name"] as? String else { return nil }
        guard let object_description    = objectDict["location_description"] as? String else { return nil }
        guard let object_accessible     = objectDict["location_accessible"] as? Bool else { return nil }
        guard let object_openair        = objectDict["location_openair"] as? Bool else { return nil }

        var object_image :ImageRef? = nil
        var object_links :[Link]? = nil
        var object_place  :Place? = nil
        
        if let includes = objectDict["include"] as? [String: Any] {
            
            if let images = includes["image"] as? [Any] {
                if let imageDict = images.first {
                    object_image = ImageRef.init(with: imageDict)
                }
            }
            if let links = includes["link"] as? [Any] {
                object_links = Link.links(from: links)
            }
            if let places = includes["place"] as? [Any] {
                if let placeDict = places.first {
                    object_place = Place.init(with: placeDict)
                }
            }
        }
        
        self.init(objectID: object_id, version: object_version, name: object_name, description: object_description, accessible: object_accessible, openair: object_openair, image: object_image, links: object_links, place: object_place)
    }
    
    /// Initializes a location with the given values.
    /// - Parameters:
    ///   - objectID: The objectID of the location. *Only applicable to locations that come from the webservice. Locally created locations do not have a distinct objectID.*
    ///   - version: The version of the location. *Only applicable to locations that come from the webservice. Locally created locations do not have a distinct version.*
    ///   - name: The name of the location.
    ///   - description: The description of the location.
    ///   - image: The image of the location.
    ///   - links: The links of the location.
    ///   - place: The place of the location.
    public init(objectID: Int = 0, version: String = "<unversioned>", name: String, description: String, accessible: Bool = false, openair: Bool = false, image: ImageRef? = nil, links: [Link]? = nil, place: Place? = nil) {
        
        self.objectID = objectID
        self.version = version
        self.name = name
        self.description = description
        self.accessible = accessible
        self.openair = openair
        
        self.image = image
        self.links = links
        self.place = place
    }
    
    /// Creates locations from an array of location dicts.
    /// - Parameter data: The dicts that contain the location values.
    /// - Returns: An array of locations or nil.
    static func locations(from data: [Any]) -> [Location]? {
        
        var locations: [Location] = []
        for objectDict in data {
            guard let location = Location.init(with: objectDict) else { return nil }
            locations.append(location)
        }
        return locations
    }
    
    /// Creates a JSON representation of the location.
    /// - Returns: The JSON representation as data.
    public func JSON() -> Data {
        
        let dict: [String: Any] = ["location_id": self.objectID, "location_version": self.version, "location_name": self.name, "location_description": self.description, "location_accessible": self.accessible, "location_openair": self.openair]
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
        hasher.combine(version)
    }
    
    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.objectID == rhs.objectID && lhs.version == rhs.version
    }
    
    public var id: Int {
        return objectID
    }
}

// MARK: LocationHandler Class

/// The LocationHandler class handles access to location objects, their associated objects and properties.
public class LocationHandler {
    
    /// The webservice to make requests to.
    var webservice: Webservice
    
    /// Initilizes the handler object.
    /// - Parameter webservice: The webservice object for makeing calls to the FestivalsAPI web service.
    init(with webservice: Webservice) {
        self.webservice = webservice
    }
    
    // MARK: Fetching locations
    
    ///  Fetches all available locations.
    /// - Parameters:
    ///     - completion: The completion will be called when the loading is done.
    ///     - locations: The fetched locations.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func all(locations completion: @escaping (_ locations: [Location]?, _ error: Error?) -> (Void)) {
        
        self.locations() { locations, error in
            
            completion(locations, error)
        }
    }
    
    ///  Fetches the locations with the given IDs.
    /// - Parameters:
    ///     - objectIDs: Th IDs of the locations you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - locations: The fetched locations.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func locations(with objectIDs: [Int]? = nil, completion: @escaping (_ locations: [Location]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetch("location", with: objectIDs, including: ["image", "link", "place"]) { (objects, error) -> (Void) in
            
            guard let objects = objects else {
                completion(nil, error)
                return
            }
            guard let locations = Location.locations(from: objects) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(locations, nil)
        }
    }
    
    ///  Fetches the location with the given ID.
    /// - Parameters:
    ///     - objectID: Th ID of the location you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - location: The fetched location.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func location(with objectID: Int, completion: @escaping (_ location: Location?, _ error: Error?) -> (Void)) {
        
        self.locations(with: [objectID]) { locations, error in
            
            guard let locations = locations else {
                completion(nil, error)
                return
            }
            guard let location = locations.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(location, nil)
        }
    }
    
    // MARK: Manage locations
    
    /// Creates the given location and returns the created location.
    /// - Parameters:
    ///     - location: The location you want to create.
    ///     - completion: The result closure will be called when the request is done.
    ///     - location: The created location.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func create(location: Location, completion: @escaping (_ location: Location?, _ error: Error?) -> (Void)) {
        
        self.webservice.create("location", with: location.JSON()) { (object, error) -> (Void) in
            
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let createdLocation = Location.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(createdLocation, nil)
        }
    }
    
    /// Updates the given location and returns the updated location.
    /// - Parameters:
    ///     - location: The location you want to update.
    ///     - completion: The result closure will be called when the request is done.
    ///     - location: The updated location.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func update(location: Location, completion: @escaping (_ location: Location?, _ error: Error?) -> (Void)) {
        
        self.webservice.update("location", with: location.objectID, and: location.JSON()) { (object, error) -> (Void) in
            
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let updatedLocation = Location.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(updatedLocation, nil)
        }
    }
    
    /// Deletes the given location.
    /// - Parameters:
    ///     - location: The location you want to delete.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the deletion was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func delete(location: Location, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.delete("location", with: location.objectID) { (success, error) -> (Void) in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage links
    
    /// Fetches the links for the given location.
    /// - Parameters:
    ///     - locationID: The ID of the location you want to fetch the links for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - links: The fetched links.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func links(for locationID: Int, completion: @escaping (_ links: [Link]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("links", for: "location", with: locationID) { (resources, error) -> (Void) in
            
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
    
    /// Associates the link with the given location.
    /// - Parameters:
    ///     - linkID: The ID of the link you want to set.
    ///     - locationID: The ID of the location you want to set the link for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(linkID: Int, for locationID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("links", with: linkID, for: "location", with: locationID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the link with the given ID and the location with the given ID.
    /// - Parameters:
    ///     - linkID: The ID of the link for which you want to remove the association.
    ///     - locationID: The ID of the location for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func remove(linkID: Int, for locationID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("links", with: linkID, for: "location", with: locationID) { success, error in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage the place
    
    /// Fetches the place for the given location.
    /// - Parameters:
    ///     - locationID: The ID of the location you want to fetch the place for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - place: The fetched place.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func place(for locationID: Int, completion: @escaping (_ place: Place?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("place", for: "location", with: locationID) { (resources, error) -> (Void) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let places = Place.places(from: resources) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            guard let place = places.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(place, nil)
        }
    }
    
    /// Associates the place with the given location.
    /// - Parameters:
    ///     - placeID: The ID of the place you want to set.
    ///     - locationID: The ID of the location you want to set the place for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(placeID: Int, for locationID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("place", with: placeID, for: "location", with: locationID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the place with the given ID and the location with the given ID.
    /// - Parameters:
    ///     - placeID: The ID of the place for which you want to remove the association.
    ///     - locationID: The ID of the location for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func remove(placeID: Int, for locationID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("place", with: placeID, for: "location", with: locationID) { success, error in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage the image
    
    /// Fetches the image for the given location.
    /// - Parameters:
    ///     - locationID: The ID of the location you want to fetch the image for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - image: The fetched image.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func image(for locationID: Int, completion: @escaping (_ image: ImageRef?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("image", for: "location", with: locationID) { (resources, error) -> (Void) in
            
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
    
    /// Associates the image with the given location.
    /// - Parameters:
    ///     - tagID: The ID of the image you want to set.
    ///     - locationID: The ID of the location you want to set the image for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(imageID: Int, for locationID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("image", with: imageID, for: "location", with: locationID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the image with the given ID and the location with the given ID.
    /// - Parameters:
    ///     - tagID: The ID of the image for which you want to remove the association.
    ///     - locationID: The ID of the location for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func remove(imageID: Int, for locationID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("image", with: imageID, for: "location", with: locationID) { success, error in
            
            completion(success, error)
        }
    }
}
