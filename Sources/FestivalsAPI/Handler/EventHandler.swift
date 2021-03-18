//
//  EventHandler.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 18.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: Event Type

/// The EventType enumeration defines a list themes an event can be associated with.
public enum EventType: Int, Codable, CaseIterable {
    /// The event is a musical performance.
    case music          = 0
    /// The event is a movie screening,
    case movie          = 1
    /// The event is an artistic performance.
    case performance    = 2
    /// The event is a theatrical performance.
    case theater        = 3
    /// The event represents a food store/restaurant.
    case food           = 4
    /// The event is an exhibition.
    case exhibition     = 5
    /// The event hosts a talk.
    case talk           = 6
    /// The event hosts a workshop.
    case workshop       = 7
}

// MARK: Event Struct

/// The  `Event` struct represents an event as it is represented in the FestivalsAPI webservice.
public class Event: ObservableObject, Hashable {
    
    /// The identifier of the event. Every objectID is unique within all event instances.
    public var objectID: Int
    /// The version of the event. Although the value is actual a timestamp, it is not recommended to perform any calcualtions that depend on the value of the timstamp.
    public var version: String
    /// The name of the event. The name must not be unique but it is highly recommended.
    public var name: String
    /// The start date of the event. Must be before the end date.
    public var start: Date
    /// The end date of the event. Must be after the start date.
    public var end: Date
    /// The description of the event.
    public var eventDescription: String
    /// The type of the event.
    public var type: EventType
    
    /// The artist associated with the event.
    @Published public var artist: Artist?
    /// The location associated with the event.
    @Published public var location: Location?
    
    /// Initializes an event with the given data.
    /// - Parameter objectDict: The dict containing the event values.
    init?(with objectDict: Any?) {
        
        guard let objectDict            = objectDict as? [String: Any] else { return nil }
        guard let object_id             = objectDict["event_id"] as? Int else { return nil }
        guard let object_version        = objectDict["event_version"] as? String else { return nil }
        guard let object_name           = objectDict["event_name"] as? String else { return nil }
        guard let object_start_int      = objectDict["event_start"] as? Int else { return nil }
        guard let object_end_int        = objectDict["event_end"] as? Int else { return nil }
        guard let object_description    = objectDict["event_description"] as? String else { return nil }
        guard let object_type           = objectDict["event_type"] as? Int else { return nil }
        guard let eventType             = EventType(rawValue: object_type) else { return nil }
        self.objectID = object_id
        self.version = object_version
        self.name = object_name
        
        #warning("We should gurantee object_start_int > object_end_int in some other place, maybe API or database?")
        if object_start_int == 0 || object_end_int == 0 || object_start_int > object_end_int {
            self.start = Date(timeIntervalSince1970: 0)
            self.end = Date(timeIntervalSince1970: 0)
        }
        else {
            self.start = Date(timeIntervalSince1970: Double(object_start_int))
            self.end = Date(timeIntervalSince1970: Double(object_end_int))
        }
        self.eventDescription = object_description
        self.type = eventType
        
        if let includes = objectDict["include"] as? [String: Any] {
            
            if let artists = includes["artist"] as? [Any] {
                if let artistDict = artists.first {
                    self.artist = Artist.init(with: artistDict)
                }
            }
            if let locations = includes["location"] as? [Any] {
                if let locationDict = locations.first {
                    self.location = Location.init(with: locationDict)
                }
            }
        }
    }
    
    /// Creates events from an array of event dicts.
    /// - Parameter data: The dicts that contain the event values.
    /// - Returns: An array of events or nil.
    static func events(from data: [Any]) -> [Event]? {
        
        var events: [Event] = []
        for objectDict in data {
            guard let event = Event(with: objectDict) else { return nil }
            events.append(event)
        }
        return events
    }
    
    /// Creates a JSON representation of the event.
    /// - Returns: The JSON representation as data.
    func JSON() -> Data {

        let dict: [String: Any] = ["event_id": self.objectID, "event_version": self.version, "event_name": self.name, "event_start": Int(self.start.timeIntervalSince1970), "event_end": Int(self.end.timeIntervalSince1970), "event_description": self.eventDescription, "event_type": self.type.rawValue]
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
    }
    
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.objectID == rhs.objectID && lhs.objectID == rhs.objectID
    }
}

// MARK: EvenHandler Class

/// The EventHandler class handles access to event objects, their associated objects and properties.
public class EventHandler {
    
    /// The webservice to make requests to.
    var webservice: Webservice
    
    /// Initilizes the handler object.
    /// - Parameter webservice: The webservice object for makeing calls to the FestivalsAPI web service.
    init(with webservice: Webservice) {
        self.webservice = webservice
    }
    
    // MARK: Fetching events
    
    ///  Fetches all available events.
    /// - Parameters:
    ///     - completion: The completion will be called when the loading is done.
    ///     - events: The fetched events.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func all(events completion: @escaping (_ events: [Event]?, _ error: Error?) -> (Void)) {
        
        self.events() { events, error in
            
            completion(events, error)
        }
    }
    
    ///  Fetches the events with the given IDs.
    /// - Parameters:
    ///     - objectIDs: Th IDs of the events you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - events: The fetched events.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func events(with objectIDs: [Int]? = nil, completion: @escaping (_ events: [Event]?, _ error: Error?) -> (Void)) {
        
        self.webservice.fetch("event", with: objectIDs, including: ["artist", "location"]) { (objects, err) -> (Void) in
            
            guard let objects = objects else {
                completion(nil, err)
                return
            }
            guard let events = Event.events(from: objects) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(events, nil)
        }
    }
    
    ///  Fetches the event with the given ID.
    /// - Parameters:
    ///     - objectID: Th ID of the event you want to fetch.
    ///     - completion: The completion will be called when the loading is done.
    ///     - event: The fetched event.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func event(with objectID: Int, completion: @escaping (_ event: Event?, _ error: Error?) -> (Void)) {
        
        self.events(with: [objectID]) { events, error in
            
            guard let events = events else {
                completion(nil, error)
                return
            }
            guard let event = events.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(event, nil)
        }
    }
    
    // MARK: Manage events
    
    /// Creates the given event and returns the created event.
    /// - Parameters:
    ///     - event: The event you want to create.
    ///     - completion: The result closure will be called when the request is done.
    ///     - event: The created event.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func create(event: Event, completion: @escaping (_ event: Event?, _ error: Error?) -> (Void)) {
        
        self.webservice.create("event", with: event.JSON()) { (object, error) -> (Void) in
        
            guard let object = object as? [String: Any] else {
                completion(nil, error)
                return
            }
            guard let createdEvent = Event(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(createdEvent, nil)
        }
    }
    
    /// Updates the given event and returns the updated event.
    /// - Parameters:
    ///     - event: The event you want to update.
    ///     - completion: The result closure will be called when the request is done.
    ///     - event: The updated event.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func update(event: Event, completion: @escaping (_ event: Event?, _ error: Error?) -> (Void)) {
        
        self.webservice.update("event", with: event.objectID, and: event.JSON()) { (object, error) -> (Void) in
        
            guard let object = object as? [String: Any] else {
                completion(nil, error)
                return
            }
            guard let updatedEvent = Event(with: object) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            completion(updatedEvent, nil)
        }
    }
    
    /// Deletes the given event.
    /// - Parameters:
    ///     - event: The event you want to delete.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the deletion was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func delete(event: Event, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.delete("event", with: event.objectID) { (success, error) -> (Void) in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage artists
    
    /// Fetches the artist for the given event.
    /// - Parameters:
    ///     - eventID: The ID of the event you want to fetch the artist for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - artist: The fetched artist.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func artist(for eventID: Int, completion: @escaping (_ artist: Artist?, _ error: Error?) -> (Void)) {
        
        let includeVals = ["image", "link", "tag"]
        self.webservice.fetchResource("artist", for: "event", with: eventID, including: includeVals) { (resources, error) -> (Void) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let artists = Artist.artists(from: resources) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            guard let artist = artists.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            completion(artist, nil)
        }
    }
    
    /// Associates the artist with the given event.
    /// - Parameters:
    ///     - artistID: The ID of the artist you want to set.
    ///     - eventID: The ID of the event you want to set the artist for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func set(artistID: Int, for eventID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("artist", with: artistID, for: "event", with: eventID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the artist with the given ID and the event with the given ID.
    /// - Parameters:
    ///     - artistID: The ID of the artist for which you want to remove the association.
    ///     - eventID: The ID of the event for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func remove(artistID: Int, for eventID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("artist", with: artistID, for: "event", with: eventID) { success, error in
            
            completion(success, error)
        }
    }
    
    // MARK: Manage the location
    
    /// Fetches the location for the given event.
    /// - Parameters:
    ///     - eventID: The ID of the event you want to fetch the location for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - location: The fetched location.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    public func location(for eventID: Int, completion: @escaping (_ location: Location?, _ error: Error?) -> (Void)) {
        
        let includeVals = ["image", "link", "place"]
        self.webservice.fetchResource("location", for: "event", with: eventID, including: includeVals) { (resources, error) -> (Void) in
            
            guard let resources = resources else {
                completion(nil, error)
                return
            }
            guard let locations = Location.locations(from: resources) else {
                completion(nil, APIError.parsingFailed)
                return
            }
            guard let location = locations.first else {
                completion(nil, APIError.recordDoesNotExist)
                return
            }
            
            completion(location, nil)
        }
    }
    
    /// Associates the location with the given event.
    /// - Parameters:
    ///     - locationID: The ID of the location you want to set.
    ///     - eventID: The ID of the event you want to set the location for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func set(locationID: Int, for eventID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.setResource("location", with: locationID, for: "event", with: eventID) { success, error in
            
            completion(success, error)
        }
    }
    
    /// Removes the association between the location with the given ID and the event with the given ID.
    /// - Parameters:
    ///     - locationID: The ID of the location for which you want to remove the association.
    ///     - eventID: The ID of the event for which you want to remove the association.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func remove(locationID: Int, for eventID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        self.webservice.removeResource("location", with: locationID, for: "event", with: eventID) { success, error in
            
            completion(success, error)
        }
    }
}
