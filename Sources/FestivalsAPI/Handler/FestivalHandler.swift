//
//  FestivalHandler.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 16.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: Festival Struct

/// The `Festival` struct represents a festival as it is represented in the FestivalsAPI webservice.
public class Festival: ObservableObject, Hashable, Identifiable {
    
    /// The identifier of the festival. Every objectID is unique within all festival instances.
    public var objectID: Int
    /// The version of the festival. Although the value is actual a timestamp, it is not recommended to perform any calcualtions that depend on the value of the timstamp.
    public var version: String
    /// Boolean value indicating if the object is valid. The value is ment to control the visibility of the object, as there are situation in which the objet should not be displayed but also not deleted altogether.
    public var valid: Bool
    /// The name of the festival. The name must not be unique but it is highly recommended.
    public var name: String
    /// The start date of the festival. Must be before the end date.
    public var start: Date
    /// The end date of the festival. Must be after the start date.
    public var end: Date
    /// The description of the festival.
    public var description: String
    /// A descritpition of the pricing of the festival.
    public var price: String
    
    /// The image associated with the festival.
    @Published public var image: ImageRef?
    /// The links associated with the festival.
    @Published public var links: [Link]?
    /// The place associated with the festival.
    @Published public var place: Place?
    /// The tags associated with the festival.
    @Published public var tags: [Tag]?
    /// The events associated with the festival.
    @Published public var events: [Event]?

    /*
    /// Initializes a festival with the given json data.
    /// - Parameter jsonData: The festival dict ecoded as json data.
    public convenience init?(resolving jsonData: Data) {
        
        guard let dict = try? JSONSerialization.jsonObject(with: jsonData, options: []) else { return nil }
        self.init(with: dict)
    }
    
    */
    
    /// Initializes a festival with the given dictionary.
    /// - Parameter objectDict: The dict containing the festival values.
    public convenience init?(with objectDict: Any?) {
        
        guard let objectDict            = objectDict as? [String: Any] else { return nil }
        guard let object_id             = objectDict["festival_id"] as? Int else { return nil }
        guard let object_version        = objectDict["festival_version"] as? String else { return nil }
        guard let object_is_valid       = objectDict["festival_is_valid"] as? Bool else { return nil }
        guard let object_name           = objectDict["festival_name"] as? String else { return nil }
        guard let object_start_int      = objectDict["festival_start"] as? Int else { return nil }
        guard let object_end_int        = objectDict["festival_end"] as? Int else { return nil }
        guard let object_description    = objectDict["festival_description"] as? String else { return nil }
        guard let object_price          = objectDict["festival_price"] as? String else { return nil }
        if object_start_int > object_end_int {
            print("Festival (\(object_name) start is before festival end.")
            return nil
        }
        let object_start = Date(timeIntervalSince1970: Double(object_start_int))
        let object_end = Date(timeIntervalSince1970: Double(object_end_int))

        var object_image: ImageRef? = nil
        var object_links: [Link]? = nil
        var object_place: Place? = nil
        var object_tags: [Tag]? = nil
        var object_events: [Event]? = nil
     
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
            if let tags = includes["tag"] as? [Any] {
                object_tags = Tag.tags(from: tags)
            }
            if let events = includes["event"] as? [Any] {
                object_events = Event.events(from: events)
            }
        }
        
        self.init(objectID: object_id, version: object_version, valid: object_is_valid, name: object_name, start: object_start, end: object_end, description: object_description, price: object_price, image: object_image, links: object_links, place: object_place, tags: object_tags, events: object_events)
    }
    
    /// Initializes a festival with the given values.
    /// - Parameters:
    ///   - objectID: The objectID of the festival. *Only applicable to festivals that come from the webservice. Locally created festivals do not have a distinct objectID.*
    ///   - version: The version of the festival. *Only applicable to festivals that come from the webservice. Locally created festivals do not have a distinct version.*
    ///   - valid: The validity of the festival.
    ///   - name: The name of the festival.
    ///   - start: The start of the festival.
    ///   - end: The end of the festival.
    ///   - description: The description of the festival.
    ///   - price: The price of the festival.
    ///   - image: The image of the festival.
    ///   - links: The links of the festival.
    ///   - place: The place of the festival.
    ///   - tags: The tags of the festival.
    ///   - events: The events of the festival.
    public init(objectID: Int = 0, version: String = "<unversioned>", valid: Bool = false, name: String, start: Date, end: Date, description: String, price: String, image: ImageRef? = nil, links: [Link]? = nil, place: Place? = nil, tags: [Tag]? = nil, events: [Event]? = nil) {
        
        self.objectID = objectID
        self.version = version
        self.valid = valid
        self.name = name
        self.start = start
        self.end = end
        self.description = description
        self.price = price
        
        self.image = image
        self.links = links
        self.place = place
        self.tags = tags
        self.events = events
    }
    
    ///  Creates a mock festival with the given name and random values.
    /// - Parameter name: The name of the festival.
    /// - Returns: The festival
    public static func mockFestival(named name: String) -> Festival {
        
        let dict: [String : Any] = ["festival_id": 0,
                                    "festival_version": "2020-02-25T\(Int.random(in: 0...23)):\(Int.random(in: 0...59)):23Z",
                                    "festival_is_valid": false,
                                    "festival_name": name,
                                    "festival_start": Int.random(in: 1596794440...1596794440+Int.random(in: 50000...200000)),
                                    "festival_end": Int.random(in: 1596794440+200000...(1596794440+200000+Int.random(in: 50000...200000))),
                                    "festival_description": "",
                                    "festival_price": "Ab \(Int.random(in: 5...35)) Euro"]
        
        return Festival(with: dict)!
    }
    
    /// Creates festivals from an array of festival dicts.
    /// - Parameter data: The dicts that contain the festival values.
    /// - Returns: An array of festivals or nil.
    static func festivals(from dicts: [Any]) -> [Festival]? {
        
        var festivals: [Festival] = []
        for objectDict in dicts {
            guard let festival = Festival(with: objectDict) else { return nil }
            festivals.append(festival)
        }
        return festivals
    }
    
    /// Creates a JSON representation of the festival.
    /// - Returns: The JSON representation as data.
    public func JSON() -> Data {
        
        let dict: [String: Any] = ["festival_id": self.objectID, "festival_version": self.version, "festival_is_valid": self.valid, "festival_name": self.name, "festival_start": Int(self.start.timeIntervalSince1970), "festival_end": Int(self.end.timeIntervalSince1970), "festival_description": self.description, "festival_price": self.price]
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public static func == (lhs: Festival, rhs: Festival) -> Bool {
        return lhs.name == rhs.name
    }
    
    public var id: Int {
        return objectID
    }
}

// MARK: FestivalHandler Class

/// The FestivalHandler class handles access to festival objects, their associated objects and properties.
public class FestivalHandler {
    
    /// The webservice to make requests to.
    var webservice: Webservice
    
    /// Initilizes the handler object.
    /// - Parameter  webservice: The webservice object for makeing calls to the FestivalsAPI web service.
    init(with webservice: Webservice) {
        self.webservice = webservice
    }
    
    // MARK: Fetch festivals
    
    ///  Fetches all available festivals.
    /// - Parameters:
    ///     - completion: The completion will be called when the loading is done.
    ///     - festivals: The fetched festivals.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func all(festivals completion: @escaping (_ festivals: [Festival]?, _ error: Error?) -> (Void)) {
        
        self.festivals() { festivals, error in
            
            completion(festivals, error)
        }
    }
    
    ///  Fetches the festivals with the given IDs.
    /// - Parameters:
    ///     - objectIDs: Th IDs of the festivals you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - festivals: The fetched festivals.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func festivals(with objectIDs: [Int]? = nil, completion: @escaping (_ festivals: [Festival]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetch("festival", with: objectIDs, including: ["image", "link", "place", "tag"]) { (objects, error) -> (Void) in
            
            guard let objects = objects else {
                completion(nil, error)
                return
            }
            guard let festivals = Festival.festivals(from: objects) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(festivals, nil)
        }
    }
    
    ///  Fetches the festival with the given ID.
    /// - Parameters:
    ///     - objectID: Th ID of the festival you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - festival: The fetched festival.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func festival(with objectID: Int, completion: @escaping (_ festival: Festival?, _ error: Error?) -> (Void)) {
        
        self.festivals(with: [objectID]) { festivals, error in
            
            guard let festivals = festivals else {
                completion(nil, error)
                return
            }
            guard let festival = festivals.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(festival, nil)
        }
    }
    
    /// Searches for festivals with the given name.
    /// - Parameters:
    ///     - name: The string that the festival name should contain.
    ///     - completion: The completion will be called when the loading is done.
    ///     - festivals: The matching festivals.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func search(with name: String, completion: @escaping (_ festivals: [Festival]?, _ error: Error?) -> (Void)) {
        
        self.webservice.search("festival", with: name) { (objects, err) -> (Void) in
            
            guard let objects = objects else {
                completion(nil, err)
                return
            }
            guard let festivals = Festival.festivals(from: objects) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(festivals, nil)
        }
    }
    
    // MARK: Manage festivals
    
    /// Creates the given festival and returns the created festival.
    /// - Parameters:
    ///     - festival: The festival you want to create.
    ///     - completion: The result closure will be called when the request is done.
    ///     - festival: The created festival.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func create(festival: Festival, completion: @escaping (_ festival: Festival?, _ error: Error?) -> (Void)) {
        
        self.webservice.create("festival", with: festival.JSON()) { (object, error) -> (Void) in
            
            guard let object = object else {
                completion(nil, error)
                return
            }
            guard let createdFestival = Festival.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(createdFestival, nil)
        }
    }
    
    /// Updates the given festival and returns the updated festival.
    /// - Parameters:
    ///     - festival: The festival you want to update.
    ///     - completion: The result closure will be called when the request is done.
    ///     - festival: The updated festival.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func update(festival: Festival, completion: @escaping (_ festival: Festival?, _ error: Error?) -> (Void)) {
        
        self.webservice.update("festival", with: festival.objectID, and: festival.JSON()) { (object, error) -> (Void) in
            
            guard let object = object as? [String: Any] else {
                completion(nil, error)
                return
            }
            guard let updatedFestival = Festival.init(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(updatedFestival, nil)
        }
    }
    
    /// Deletes the given festival.
    /// - Parameters:
    ///     - festival: The festival you want to delete.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the deletion was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func delete(festival: Festival, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.delete("festival", with: festival.objectID) { (success, error) -> (Void) in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage events
    
    /// Fetches the events for the given festival.
    /// - Parameters:
    ///     - festivalID: The ID of the festival you want to fetch the events for.
    ///     - includes: Boolean value indicating if you want the events to include their related objects.
    ///     - completion: The result closure will be called when the request is done.
    ///     - events: The fetched events.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func events(for festivalID: Int, with includes: Bool, completion: @escaping (_ events: [Event]?, _ error: Error?) -> (Void)) {
        
        let includeVals = (includes) ? ["artist","location"] : []
        self.webservice.fetchResource("events", for: "festival", with: festivalID, including: includeVals) { (resources, error) -> (Void) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
        
            guard let events = Event.events(from: resources) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(events, nil)
        }
    }
    
    /// Associates the event with the given festival.
    /// - Parameters:
    ///     - eventID: The ID of the event you want to set.
    ///     - festivalID: The ID of the festival you want to set the event for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(eventID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("events", with: eventID, for: "festival", with: festivalID) { success, error in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage links
    
    /// Fetches the links for the given festival.
    /// - Parameters:
    ///     - festivalID: The ID of the festival you want to fetch the links for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - links: The fetched links.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func links(for festivalID: Int, completion: @escaping (_ links: [Link]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("links", for: "festival", with: festivalID) { (resources, error) -> (Void) in
            
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
    
    /// Associates the link with the given festival.
    /// - Parameters:
    ///     - linkID: The ID of the link you want to set.
    ///     - festivalID: The ID of the festival you want to set the link for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(linkID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("links", with: linkID, for: "festival", with: festivalID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the link with the given ID and the festival with the given ID.
    /// - Parameters:
    ///     - linkID: The ID of the link for which you want to remove the association.
    ///     - festivalID: The ID of the festival for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func remove(linkID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("links", with: linkID, for: "festival", with: festivalID) { success, error in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage the place
    
    /// Fetches the place for the given festival.
    /// - Parameters:
    ///     - festivalID: The ID of the festival you want to fetch the place for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - place: The fetched place.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func place(for festivalID: Int, completion: @escaping (_ place: Place?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("place", for: "festival", with: festivalID) { (resources, error) -> (Void) in
            
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
    
    /// Associates the place with the given festival.
    /// - Parameters:
    ///     - placeID: The ID of the place you want to set.
    ///     - festivalID: The ID of the festival you want to set the place for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(placeID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("place", with: placeID, for: "festival", with: festivalID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the place with the given ID and the festival with the given ID.
    /// - Parameters:
    ///     - placeID: The ID of the place for which you want to remove the association.
    ///     - festivalID: The ID of the festival for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func remove(placeID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("place", with: placeID, for: "festival", with: festivalID) { success, error in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage tags
    
    /// Fetches the tags for the given festival.
    /// - Parameters:
    ///     - festivalID: The ID of the festival you want to fetch the tags for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - tags: The fetched tags.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func tags(for festivalID: Int, completion: @escaping (_ tags: [Tag]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("tags", for: "festival", with: festivalID) { (resources, error) -> (Void) in
            
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
    
    /// Associates the tag with the given festival.
    /// - Parameters:
    ///     - tagID: The ID of the tag you want to set.
    ///     - festivalID: The ID of the festival you want to set the tag for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(tagID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("tags", with: tagID, for: "festival", with: festivalID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the tag with the given ID and the festival with the given ID.
    /// - Parameters:
    ///     - tagID: The ID of the tag for which you want to remove the association.
    ///     - festivalID: The ID of the festival for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func remove(tagID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("tags", with: tagID, for: "festival", with: festivalID) { success, error in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage the image
    
    /// Fetches the image for the given festival.
    /// - Parameters:
    ///     - festivalID: The ID of the festival you want to fetch the image for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - image: The fetched image.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func image(for festivalID: Int, completion: @escaping (_ image: ImageRef?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("image", for: "festival", with: festivalID) { (resources, error) -> (Void) in
            
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
    
    /// Associates the image with the given festival.
    /// - Parameters:
    ///     - tagID: The ID of the image you want to set.
    ///     - festivalID: The ID of the festival you want to set the image for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func set(imageID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("image", with: imageID, for: "festival", with: festivalID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the image with the given ID and the festival with the given ID.
    /// - Parameters:
    ///     - tagID: The ID of the image for which you want to remove the association.
    ///     - festivalID: The ID of the festival for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func remove(imageID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("image", with: imageID, for: "festival", with: festivalID) { success, error in
            
            completion(success, error)
        }
    }
}
