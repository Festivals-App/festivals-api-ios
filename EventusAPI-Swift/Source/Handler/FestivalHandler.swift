//
//  FestivalHandler.swift
//  EventusAPI-Swift
//
//  Created by Simon Gaus on 16.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: Festival Struct

/// The `Festival` struct represents a festival as it is represented in the Eventus webservice.
struct Festival: Codable {
    
    /// The identifier of the festival. Every objectID is unique within all festival instances.
    var objectID: Int
    /// The version of the festival. Although the value is actual a timestamp, it is not recommended to perform any calcualtions that depend on the value of the timstamp.
    var version: String
    /// Boolean value indicating if the object is valid. The value is ment to control the visibility of the object, as there are situation in which the objet should not be displayed but also not deleted altogether.
    var valid: Bool
    /// The name of the festival. The name must not be unique but it is highly recommended.
    var name: String
    /// The start date of the festival. Must be before the end date.
    var start: Date
    /// The end date of the festival. Must be after the start date.
    var end: Date
    /// The description of the festival.
    var description: String
    /// A descritpition of the pricing of the festival.
    var price: String
    
    /// The image associated with the festival.
    var image: ImageRef?
    /// The links associated with the festival.
    var links: [Link]?
    /// The place associated with the festival.
    var place: Place?
    /// The tags associated with the festival.
    var tags: [Tag]?
    /// The events associated with the festival.
    var events: [Event]?
    
    /// Initializes a festival with the given data.
    /// - Parameter objectDict: The dict containing the festival values.
    init?(with objectDict: Any?) {
        
        guard let objectDict            = objectDict as? [String: Any] else { return nil }
        guard let object_id             = objectDict["festival_id"] as? Int else { return nil }
        guard let object_version        = objectDict["festival_version"] as? String else { return nil }
        guard let object_is_valid       = objectDict["festival_is_valid"] as? Bool else { return nil }
        guard let object_name           = objectDict["festival_name"] as? String else { return nil }
        guard let object_start_int      = objectDict["festival_start"] as? Int else { return nil }
        guard let object_end_int        = objectDict["festival_end"] as? Int else { return nil }
        guard let object_description    = objectDict["festival_description"] as? String else { return nil }
        guard let object_price          = objectDict["festival_price"] as? String else { return nil }
        self.objectID = object_id
        self.version = object_version
        self.valid = object_is_valid
        self.name = object_name
        self.start = Date.init(timeIntervalSince1970: Double(object_start_int))
        self.end = Date.init(timeIntervalSince1970: Double(object_end_int))
        self.description = object_description
        self.price = object_price
        
        if let includes = objectDict["include"] as? [String: Any] {
            
            if let images = includes["image"] as? [Any] {
                if let imageDict = images.first {
                    self.image = ImageRef.init(with: imageDict)
                }
            }
            if let links = includes["link"] as? [Any] {
                self.links = Link.links(from: links)
            }
            if let places = includes["place"] as? [Any] {
                if let placeDict = places.first {
                    self.place = Place.init(with: placeDict)
                }
            }
            if let tags = includes["tag"] as? [Any] {
                self.tags = Tag.tags(from: tags)
            }
            if let events = includes["event"] as? [Any] {
                self.events = Event.events(from: events)
            }
        }
    }
    
    /// Creates festivals from an array of festival dicts.
    /// - Parameter data: The dicts that contain the festival values.
    /// - Returns: An array of festivals or nil.
    static func festivals(from data: [Any]) -> [Festival]? {
        
        var festivals: [Festival] = []
        for objectDict in data {
            guard let festival = Festival.init(with: objectDict) else { return nil }
            festivals.append(festival)
        }
        return festivals
    }
    
    /// Creates a JSON representation of the festival.
    /// - Returns: The JSON representation as data.
    func JSON() -> Data {
        
        let dict: [String: Any] = ["festival_id": self.objectID, "festival_version": self.version, "festival_is_valid": self.valid, "festival_name": self.name, "festival_start": Int(self.start.timeIntervalSince1970), "festival_end": Int(self.end.timeIntervalSince1970), "festival_description": self.description, "festival_price": self.price]
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }
}

// MARK: FestivalHandler Class

/// The FestivalHandler class handles access to festival objects, their associated objects and properties.
class FestivalHandler {
    
    /// The webservice to make requests to.
    var webservice: Webservice
    
    /// Initilizes the handler object.
    /// - Parameter  webservice: The webservice object for makeing calls to the Eventus web service.
    init(with webservice: Webservice) {
        self.webservice = webservice
    }
    
    // MARK: Fetch festivals
    
    ///  Fetches all available festivals.
    /// - Parameters:
    ///     - completion: The completion will be called when the loading is done.
    ///     - festivals: The fetched festivals.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func all(festivals completion: @escaping (_ festivals: [Festival]?, _ error: Error?) -> (Void)) {
        
        self.festivals(with: nil) { festivals, error in
            
            completion(festivals, error)
        }
    }
    
    ///  Fetches the festivals with the given IDs.
    /// - Parameters:
    ///     - objectIDs: Th IDs of the festivals you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - festivals: The fetched festivals.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func festivals(with objectIDs: [Int]?, completion: @escaping (_ festivals: [Festival]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetch("festival", with: objectIDs, including: ["image", "link", "place", "tag"]) { (objects, err) -> (Void) in
            
            guard let objects = objects else {
                completion(nil, err)
                return
            }
            guard let festivals = Festival.festivals(from: objects) else {
                completion(nil, err)
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
    func festival(with objectID: Int, completion: @escaping (_ festival: Festival?, _ error: Error?) -> (Void)) {
        
        self.festivals(with: [objectID]) { festivals, error in
            
            guard let festivals = festivals else {
                completion(nil, error)
                return
            }
            guard let festival = festivals.first else {
                completion(nil, error)
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
    func search(with name: String, completion: @escaping (_ festivals: [Festival]?, _ error: Error?) -> (Void)) {
        
        self.webservice.search("festival", with: name) { (objects, err) -> (Void) in
            
            guard let objects = objects else {
                completion(nil, err)
                return
            }
            guard let festivals = Festival.festivals(from: objects) else {
                completion(nil, err)
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
    func create(festival: Festival, completion: @escaping (_ festival: Festival?, _ error: Error?) -> (Void)) {
        
        self.webservice.create("festival", with: festival.JSON()) { (object, error) -> (Void) in
            
            guard let object = object as? [String: Any] else {
                completion(nil, error)
                return
            }
            guard let createdFestival = Festival.init(with: object) else {
                completion(nil, error)
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
    func update(festival: Festival, completion: @escaping (_ festival: Festival?, _ error: Error?) -> (Void)) {
        
        self.webservice.update("festival", with: festival.objectID, and: festival.JSON()) { (object, error) -> (Void) in
            
            guard let object = object as? [String: Any] else {
                completion(nil, error)
                return
            }
            guard let updatedFestival = Festival.init(with: object) else {
                completion(nil, error)
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
    func delete(festival: Festival, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
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
    func events(for festivalID: Int, with includes: Bool, completion: @escaping (_ events: [Event]?, _ error: Error?) -> (Void)) {
        
        let includeVals = (includes) ? ["artist","location"] : []
        self.webservice.fetchResource("events", for: "festival", with: festivalID, including: includeVals) { (resources, error) -> (Void) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let events = Event.events(from: resources) else {
                completion(nil, error)
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
    func set(eventID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
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
    func links(for festivalID: Int, completion: @escaping (_ links: [Link]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("links", for: "festival", with: festivalID, including: nil) { (resources, error) -> (Void) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let links = Link.links(from: resources) else {
                completion(nil, error)
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
    func set(linkID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
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
    func remove(linkID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
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
    func place(for festivalID: Int, completion: @escaping (_ place: Place?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("place", for: "festival", with: festivalID, including: nil) { (resources, error) -> (Void) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let places = Place.places(from: resources) else {
                completion(nil, error)
                return
            }
            guard let place = places.first else {
                completion(nil, error)
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
    func set(placeID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
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
    func remove(placeID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
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
    func tags(for festivalID: Int, completion: @escaping (_ tags: [Tag]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("tags", for: "festival", with: festivalID, including: nil) { (resources, error) -> (Void) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let tags = Tag.tags(from: resources) else {
                completion(nil, error)
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
    func set(tagID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
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
    func remove(tagID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
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
    func image(for festivalID: Int, completion: @escaping (_ image: ImageRef?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetchResource("image", for: "festival", with: festivalID, including: nil) { (resources, error) -> (Void) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let images = ImageRef.imageRefs(from: resources) else {
                completion(nil, error)
                return
            }
            guard let image = images.first else {
                completion(nil, error)
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
    func set(imageID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
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
    func remove(imageID: Int, for festivalID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("image", with: imageID, for: "festival", with: festivalID) { success, error in
            
            completion(success, error)
        }
    }
}
