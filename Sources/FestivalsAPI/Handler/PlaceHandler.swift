//
//  PlaceHandler.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 18.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: Place Struct

/// The `Place` struct represents a place as it is represented in the FestivalsAPI webservice.
public struct Place: Codable, Hashable, Identifiable {
    
    /// The identifier of the place. Every objectID is unique within all place instances.
    public var objectID: Int
    /// The version of the festival. Although the value is actual a timestamp, it is not recommended to perform any calcualtions that depend on the value of the timstamp.
    public var version: String
    /// The street associated with the place.
    public var street: String
    /// The zip code associated with the place.
    public var zip: String
    /// The town associated with the place.
    public var town: String
    /// The street addition associated with the place.
    public var streetAddition: String
    /// The country associated with the place.
    public var country: String
    /// The latitude of the place.
    public var lat: Decimal
    /// The longitude of the place.
    public var lon: Decimal
    /// The description of the place.
    public var description: String
    
    /// Initializes a place with the given data.
    /// - Parameter objectDict: The dict containing the place values.
    public init?(with objectDict: Any?) {
        
        guard let objectDict                = objectDict as? [String: Any] else { return nil }
        guard let object_id                 = objectDict["place_id"] as? Int else { return nil }
        guard let object_version            = objectDict["place_version"] as? String else { return nil }
        guard let object_street             = objectDict["place_street"] as? String else { return nil }
        guard let object_zip                = objectDict["place_zip"] as? String else { return nil }
        guard let object_town               = objectDict["place_town"] as? String else { return nil }
        guard let object_street_addition    = objectDict["place_street_addition"] as? String else { return nil }
        guard let object_country            = objectDict["place_country"] as? String else { return nil }
        guard let object_lat                = objectDict["place_lat"] as? Double else { return nil }
        guard let object_lon                = objectDict["place_lon"] as? Double else { return nil }
        guard let object_description        = objectDict["place_description"] as? String else { return nil }
        
        self.init(objectID: object_id, version: object_version, street: object_street, zip: object_zip, town: object_town, streetAddition: object_street_addition, country: object_country, lat: Decimal(object_lat), lon: Decimal(object_lon), description: object_description)
    }
    
    /// Initializes a place with the given values.
    /// - Parameters:
    ///   - objectID: The objectID of the place. *Only applicable to places that come from the webservice. Locally created places do not have a distinct objectID.*
    ///   - name: The name of the tag.
    
    
    
    
    /// Initializes a place with the given values.
    /// - Parameters:
    ///   - objectID: The objectID of the place. *Only applicable to places that come from the webservice. Locally created places do not have a distinct objectID.*
    ///   - version: The version of the place. *Only applicable to places that come from the webservice. Locally created places do not have a valid version.*
    ///   - street: The street of the place.
    ///   - zip: The zip of the place.
    ///   - town: The town of the place.
    ///   - streetAddition: The streetAddition of the place.
    ///   - country: The country of the place.
    ///   - lat: The lat of the place.
    ///   - lon: The lon of the place.
    ///   - description: The description of the place.
    public init(objectID: Int = 0, version: String = "<unversioned>", street: String = "", zip: String = "", town: String = "", streetAddition: String = "", country: String = "", lat: Decimal = Decimal(), lon: Decimal = Decimal(), description: String = "") {
        self.objectID = objectID
        self.version = version
        self.street = street
        self.zip = zip
        self.town = town
        self.streetAddition = streetAddition
        self.country = country
        self.lat = lat
        self.lon = lon
        self.description = description
    }
    
    /// Creates places from an array of place dicts.
    /// - Parameter data: The dicts that contain the place values.
    /// - Returns: An array of places or nil.
    static func places(from data: [Any]) -> [Place]? {
        
        var places: [Place] = []
        for objectDict in data {
            guard let place = Place.init(with: objectDict) else { return nil }
            places.append(place)
        }
        return places
    }
    
    /// Creates a JSON representation of the festival.
    /// - Returns: The JSON representation as data.
    public func JSON() -> Data {

        let dict: [String: Any] = ["place_id": self.objectID, "place_version": self.version, "place_street": self.street, "place_zip": self.zip, "place_town": self.town, "place_street_addition": self.streetAddition, "place_country": self.country, "place_lat": self.lat, "place_lon": self.lon, "place_description": self.description]
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
        hasher.combine(version)
    }
    
    public static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.objectID == rhs.objectID && lhs.version == rhs.version
    }
    
    public var id: Int {
        return objectID
    }
}

// MARK: PlaceHandler Class

/// The PlaceHandler class handles access to place objects, their associated objects and properties.
public class PlaceHandler {
    
    /// The webservice to make requests to.
    var webservice: Webservice
    
    // MARK: Initialization
    
    /// Initilizes the handler object.
    /// - Parameter webservice: The webservice object for makeing calls to the FestivalsAPI web service.
    init(with webservice: Webservice) {
        self.webservice = webservice
    }
    
    // MARK: Fetch places
    
    ///  Fetches all available places.
    /// - Parameters:
    ///     - completion: The completion will be called when the loading is done.
    ///     - places: The fetched places.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func all(places completion: @escaping (_ places: [Place]?, _ error: Error?) -> (Void)) {
        
        self.places() { places, error in
            
            completion(places, error)
        }
    }
    
    ///  Fetches the places with the given IDs.
    /// - Parameters:
    ///     - objectIDs: Th IDs of the places you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - places: The fetched places.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func places(with objectIDs: [Int]? = nil, completion: @escaping (_ places: [Place]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetch("place", with: objectIDs) { (objects, err) -> (Void) in
            
            guard let objects = objects else {
                completion(nil, err)
                return
            }
            guard let places = Place.places(from: objects) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(places, nil)
        }
    }
    
    ///  Fetches the place with the given ID.
    /// - Parameters:
    ///     - objectID: Th ID of the place you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - place: The fetched place.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func place(with objectID: Int, completion: @escaping (_ place: Place?, _ error: Error?) -> (Void)) {
        
        self.places(with: [objectID]) { (places, error) -> (Void) in
            
            guard let places = places else {
                completion(nil, error)
                return
            }
            guard let place = places.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(place, nil)
        }
    }
    
    // MARK: Manage places
    
    /// Creates the given place and returns the created place.
    /// - Parameters:
    ///     - place: The place you want to create.
    ///     - completion: The result closure will be called when the request is done.
    ///     - place: The created place.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func create(place: Place, completion: @escaping (_ place: Place?, _ error: Error?) -> (Void)) {
        
        self.webservice.create("place", with: place.JSON()) { (object, error) -> (Void) in
        
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let createdPlace = Place.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(createdPlace, nil)
        }
    }
    
    /// Updates the given place and returns the updated place.
    /// - Parameters:
    ///     - place: The place you want to update.
    ///     - completion: The result closure will be called when the request is done.
    ///     - place: The updated place.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func update(place: Place, completion: @escaping (_ place: Place?, _ error: Error?) -> (Void)) {
        
        self.webservice.update("place", with: place.objectID, and: place.JSON()) { (object, error) -> (Void) in
        
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let updatedPlace = Place.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(updatedPlace, nil)
        }
    }
    
    /// Deletes the given place.
    /// - Parameters:
    ///     - place: The place you want to delete.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the deletion was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func delete(place: Place, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.delete("place", with: place.objectID) { (success, error) -> (Void) in
            
            completion(success, error)
        }
    }
}
