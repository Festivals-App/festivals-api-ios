//
//  Webservice.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 11.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: HTTTP Request Values

/// The HTTP methodes used by the webservice.
enum HTTPMethode: String {
    /// The GET method requests a representation of the specified resource. Requests using GET should only retrieve data.
    case GET = "GET"
    /// The POST method is used to submit an entity to the specified resource, often causing a change in state or side effects on the server.
    case POST = "POST"
    /// The PATCH method is used to apply partial modifications to a resource.
    case PATCH = "PATCH"
    /// The DELETE method deletes the specified resource.
    case DELETE = "DELETE"
}

/// The HTTP header fields used by the webservice.
enum HTTPHeaderField: String {
    /// The Content-Length entity-header field indicates the size of the entity-body, in decimal number of OCTETs.
    case ContentLengt = "Content-Length"
    /// The Content-Type entity header is used to indicate the media type of the resource.
    case ContentType = "Content-Type"
}

/// The content types used by the webservice.
enum HTTPContentType: String {
    /// JSON format
    case ContentTypeJSON = "application/json"
}

// MARK: Implementation

/// This class is responsible for consuming the FestivalsAPI web service's REST API and provides methodes for all available API requests.
class Webservice: NSObject {
    
    /// The base url to send the requests to .
    var baseURL: URL
    /// The session to use for requests.
    var session: URLSession
    /// The version of the web api to use.
    var apiVersion: String
    /// The timeout for making requests.
    var requestTimeout = 60.0
    
    // MARK: Initialization
    
    /// Initilizes the webservice object.
    /// - Parameters:
    ///     - baseURL: The base URL used for makeing calls to the FestivalsAPI web service.
    ///     - session: The session used for requests.
    ///     - apiKey: The API key used for making requests.
    init(baseURL: URL, session: URLSession, apiKey: String, apiVersion: APIVersion) {
        
        self.baseURL = baseURL
        session.configuration.httpAdditionalHeaders = ["API-KEY": apiKey]
        self.session = session
        self.apiVersion = apiVersion.rawValue
    }
    
    // MARK: Manage Objects
    
    /// Fetches objects of the given object type including the specified related objects. Additionaly you can filter the result by specifying the IDs to fetch.
    /// - Parameters:
    ///     - objectType: The object type to fetch.
    ///     - ids: The IDs to fetch.
    ///     - relationships: The related objects to include.
    ///     - completion: The result closure will be called when the request is done.
    ///     - objects: The fetched objects.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func fetch(_ objectType: String, with ids: [Int]?, including relationships: [String]? = nil, completion: @escaping (_ objects: [Any]?, _ error: Error?) -> (Void)) {
        
        let query = self.makeFetchQuery(with: objectType, ids, including: relationships)
        let queryURL = self.baseURL.absoluteString.appending(query)
        let request = self.makeRequest(with: URL.init(string: queryURL)!, .GET, and: nil)
        
        self.perfrom(request) { (data, err) -> (Void) in
            
            completion(data, err)
        }
    }
    
    /// Creates the given object and returns the newly created object.
    /// - Parameters:
    ///     - objectType: The type of object you want to create.
    ///     - data: The JSON representation of the object you want to create as data.
    ///     - completion: The result closure will be called when the request is done.
    ///     - object: The created object.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func create(_ objectType: String, with data: Data, completion: @escaping (_ object: Any?, _ error: Error?) -> (Void)) {
        
        let query = self.makeCreateQuery(for: objectType)
        let queryURL = self.baseURL.absoluteString.appending(query)
        let request = self.makeRequest(with: URL.init(string: queryURL)!, .POST, and: data)
        
        self.perfrom(request) { (data, err) -> (Void) in
            
            guard let objects = data else {
                completion(nil, err)
                return
            }
            guard let object = objects.first else {
                completion(nil, APIError.unknownError)
                return
            }
            completion(object, nil)
        }
    }
    
    /// Creates the given object and returns the newly created object.
    /// - Parameters:
    ///     - objectType: The type of object you want to create.
    ///     - data: The JSON representation of the object you want to create as data.
    ///     - completion: The result closure will be called when the request is done.
    ///     - object: The created object.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func update(_ objectType: String, with id: Int, and data: Data, completion: @escaping (_ object: Any?, _ error: Error?) -> (Void)) {
        
        let query = self.makeUpdateQuery(for: objectType, with: id)
        let queryURL = self.baseURL.absoluteString.appending(query)
        let request = self.makeRequest(with: URL.init(string: queryURL)!, .PATCH, and: data)
        
        self.perfrom(request) { (data, err) -> (Void) in
            
            guard let objects = data else {
                completion(nil, err)
                return
            }
            guard let object = objects.first else {
                completion(nil, APIError.unknownError)
                return
            }
            completion(object, nil)
        }
    }
    
    /// Deletes the given object.
    /// - Parameters:
    ///     - objectType: The type of object you want to delete.
    ///     - id: The ID of the object you want to delete.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the deletion was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func delete(_ objectType: String, with id: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        let query = self.makeDeleteQuery(for: objectType, with: id)
        let queryURL = self.baseURL.absoluteString.appending(query)
        let request = self.makeRequest(with: URL.init(string: queryURL)!, .DELETE, and: nil)
        
        self.perfrom(request) { (data, err) -> (Void) in
            
            guard let _ = data else {
                completion(false, err)
                return
            }
            completion(true, nil)
        }
    }
    
    // MARK: Search Objects
    
    /// Searches and fetches objects of the given object type that match the provided name.
    /// - Parameters:
    ///     - objectType: The object type to fetch.
    ///     - name: The name of the objects to fetch.
    ///     - completion: The result closure will be called when the request is done.
    ///     - objects: The fetched objects.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func search(_ objectType: String, with name: String, completion: @escaping (_ objects: [Any]?, _ error: Error?) -> (Void)) {
        
        let query = self.makeSearchQuery(for: objectType, with: name)
        let queryURL = self.baseURL.absoluteString.appending(query)
        let request = self.makeRequest(with: URL.init(string: queryURL)!, .GET, and: nil)
        
        self.perfrom(request) { (data, err) -> (Void) in
            
            completion(data, err)
        }
    }
    
    // MARK: Manage Resources
    
    /// Fetches the resource of the given object type for the specifiyed object including the specified related objects.
    /// - Parameters:
    ///     - resourceType: The resource to fetch.
    ///     - objectType: The object type to fetch the resource for.
    ///     - id:  The object ID to fetch the resource for.
    ///     - relationships: The related objects to include.
    ///     - completion: The result closure will be called when the request is done.
    ///     - resources: The fetched resource objects.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func fetchResource(_ resourceType: String, for objectType: String, with id: Int, including relationships: [String]? = nil, completion: @escaping (_ resources: [Any]?, _ error: Error?) -> (Void)) {
    
        let query = self.makeFetchResourceQuery(with: resourceType, for: objectType, id, including: relationships)
        let queryURL = self.baseURL.absoluteString.appending(query)
        let request = self.makeRequest(with: URL.init(string: queryURL)!, .GET, and: nil)
        
        self.perfrom(request) { (data, err) -> (Void) in

            completion(data, err)
        }
    }
    
    /// Sets the resource of the given object type for the specifiyed object.
    /// - Parameters:
    ///     - resourceName: The resource to set.
    ///     - resourceID: The ID of the resource to set.
    ///     - objectType:  The object type to set the resource for.
    ///     - objectID: The object ID to set the resource for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the set operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func setResource(_ resourceName: String, with resourceID: Int, for objectType: String, with objectID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        let query = self.makeSetResourceQuery(for: resourceName, with: resourceID, and: objectType, with: objectID)
        let queryURL = self.baseURL.absoluteString.appending(query)
        let request = self.makeRequest(with: URL.init(string: queryURL)!, .POST, and: nil)
        
        self.perfrom(request) { (data, err) -> (Void) in
            
            guard let _ = data else {
                completion(false, err)
                return
            }
            completion(true, nil)
        }
    }
    
    /// Removes the resource of the given object type for the specifiyed object.
    /// - Parameters:
    ///     - resourceName: The resource to remove.
    ///     - resourceID: The ID of the resource to remove.
    ///     - objectType:  The object type to remove the resource for.
    ///     - objectID: The object ID to remove the resource for.
    ///     - completion: The result closure will be called when the request is done.
    ///     - success: Boolean value indicating if the remove operation was successfull.
    ///     - error: If the request failed the error can provide more information about the failure reason.
    func removeResource(_ resourceName: String, with resourceID: Int, for objectType: String, with objectID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> (Void)) {
        
        let query = self.makeRemoveResourceQuery(for: resourceName, with: resourceID, and: objectType, with: objectID)
        let queryURL = self.baseURL.absoluteString.appending(query)
        let request = self.makeRequest(with: URL.init(string: queryURL)!, .DELETE, and: nil)
        
        self.perfrom(request) { (data, err) -> (Void) in
            
            guard let _ = data else {
                completion(false, err)
                return
            }
            completion(true, nil)
        }
    }
    
    // MARK: Perform Requests
    
    /// Runs the given request. If the request was successful the result closure will return the data object, otherwise an error is returned.
    /// - Note:See https://github.com/Festivals-App/festivals-server/wiki/Festivals-API-Documentation
    /// - Parameters:
    ///     - request: The request to run.
    ///     - result: The result closure will be called when the request is done.
    ///     - data: The data object if the request was successful.
    ///     - error: The error if the request failed.
    func perfrom(_ request: URLRequest, result: @escaping (_ data: [Any]?, _ error: Error?) -> (Void)) {
        
        self.session.dataTask(with: request) { (data, response, err) in
           
            DispatchQueue.main.async {
                // no response is bad
                guard  let _ = response as? HTTPURLResponse else{
                    result(nil, APIError.requestFailed)
                    return
                }
                // no data is bad, as the FestivalsAPI service always returns data
                guard let jsonData = data else {
                    if let err = err {
                        print(err)
                    }
                    result(nil, APIError.requestFailed)
                    return
                }
                // retrieve data array if possible
                guard let dataArray = self.dataArrayFrom(jsonData) else {
                    result(nil, APIError.serviceError)
                    return
                }
                result(dataArray, nil)
            }
        }.resume()
    }
    
    // MARK: Result Parsing
    
    /// Parses the json data and retrieves the data array if possible.
    /// - Parameter jsonData: The json data.
    /// - Returns: The data array or nil.
    func dataArrayFrom(_ jsonData: Data) -> [Any]? {
        
        let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
        if let dictionary = json as? [String: Any] {
            
            if let data = dictionary["data"] as? [Any] {
                return data
            }
            if let _ = dictionary["data"] as? NSNull {
                return []
            }
            if let performError = dictionary["error"] {
                print(performError)
            }
            return nil
        }
        return nil
    }
    
    // MARK: Request Creation
    
    /// Creates and returns a URLRequest with the given argumens .
    /// - Parameters:
    ///     - url: The url for the request.
    ///     - methode: The HTTP methode used for the request.
    ///     - data: The data if any.
    /// - Returns: The configured request.
    func makeRequest(with url: URL, _ methode: HTTPMethode, and data: Data?) -> URLRequest {
        
        let request = NSMutableURLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: self.requestTimeout)
        request.httpMethod = methode.rawValue
        
        if let data = data {
            request.addValue(HTTPContentType.ContentTypeJSON.rawValue, forHTTPHeaderField: HTTPHeaderField.ContentType.rawValue)
            request.addValue(String(data.count), forHTTPHeaderField: HTTPHeaderField.ContentLengt.rawValue)
            request.httpBody = data
        }
        
        return request.copy() as! URLRequest
    }
    
    // MARK: Query Creation
    
    /// Creates the query string for a fetch request
    /// - Parameters:
    ///     - objectType: The object type you want to fetch.
    ///     - objectIDs: The IDs to fetch.
    ///     - relationships: The related objects to include if any.
    /// - Returns: The query string.
    func makeFetchQuery(with objectType: String, _ objectIDs: [Int]? = nil, including relationships: [String]? = nil) -> String {
        
        var queryString: String
        
        var multipleIDs: String? = nil
        var singleID: String? = nil
        var includes: String? = nil
        
        if let objectIDs = objectIDs {
            if objectIDs.count > 1 {
                multipleIDs = objectIDs.map { String($0) }.joined(separator: ",")
            } else {
                if let single = objectIDs.first {
                    singleID = String(single)
                }
            }
        }
        if let relationships = relationships {
            includes = relationships.joined(separator: ",")
        }
        
        if let multipleIDs = multipleIDs {
            queryString = "/\(objectType)s?ids=\(multipleIDs)"
            if let includes = includes {
                queryString = queryString + "&include=\(includes)"
            }
        } else if let singleID = singleID {
            queryString = "/\(objectType)s/\(singleID)"
            if let includes = includes {
                queryString = queryString + "?include=\(includes)"
            }
        } else {
            queryString = "/\(objectType)s"
            if let includes = includes {
                queryString = queryString + "?include=\(includes)"
            }
        }
     
        return queryString
    }
    
    /// Creates the query string for an object creation request
    /// - Parameter objectType: The type of object you want to create.
    /// - Returns: The query string.
    func makeCreateQuery(for objectType: String) -> String {
        
        return "/\(objectType)s"
    }
    
    /// Creates the query string for an object update request
    /// - Parameter objectType: The type of object you want to update.
    /// - Parameter objectID: The ID of the object you want to update.
    /// - Returns: The query string.
    func makeUpdateQuery(for objectType: String, with objectID: Int) -> String {
        
        return "/\(objectType)s/\(objectID)"
    }
    
    /// Creates the query string for an object delete request
    /// - Parameter objectType: The type of object you want to delete.
    /// - Parameter objectID: The ID of the object you want to delete.
    /// - Returns: The query string.
    func makeDeleteQuery(for objectType: String, with objectID: Int) -> String {
        
        return "/\(objectType)s/\(objectID)"
    }
    
    /// Creates the query string for a search request
    /// - Parameters:
    ///     - objectType: The object type you want to fetch.
    ///     - name: The object name to search.
    /// - Returns: The query string.
    func makeSearchQuery(for objectType: String, with name: String) -> String {
        
        return "/\(objectType)s?name=\(name)"
    }
    
    /// Creates the query string for a resource fetch request
    /// - Parameters:
    ///     - relationshipName: The relationship name of the resource you want to fetch.
    ///     - objectType: The object type you want to fetch the resource for.
    ///     - objectID: The ID of the object you want to fetch the resource for.
    ///     - relationships: The related objects to include if any.
    /// - Returns: The query string.
    func makeFetchResourceQuery(with relationshipName: String, for objectType: String, _ objectID: Int, including relationships: [String]?) -> String {
    
        var queryString = "/\(objectType)s/\(objectID)/\(relationshipName)"
        
        if let relationships = relationships {
            queryString = queryString + "?include=" + relationships.joined(separator: ",")
        }
        
        return queryString
    }
    
    /// Creates the query string for a resource set request.
    /// - Parameters:
    ///     - resourceName: The name of the resource you want to set.
    ///     - resourceID: The ID of the resource you want to set.
    ///     - objectType: The type of the object you want to set the resource for.
    ///     - objectID: The ID of the object you want to set the resource for.
    /// - Returns: The query string.
    func makeSetResourceQuery(for resourceName: String, with resourceID: Int, and objectType: String, with objectID: Int) -> String {
    
        return "/\(objectType)s/\(objectID)/\(resourceName)/\(resourceID)"
    }
    
    /// Creates the query string for a resource remove request.
    /// - Parameters:
    ///     - resourceName: The name of the resource you want to remove.
    ///     - resourceID: The ID of the resource you want to remove.
    ///     - objectType: The type of the object you want to remove the resource for.
    ///     - objectID: The ID of the object you want to remove the resource for.
    /// - Returns: The query string.
    func makeRemoveResourceQuery(for resourceName: String, with resourceID: Int, and objectType: String, with objectID: Int) -> String {
    
        return "/\(objectType)s/\(objectID)/\(resourceName)/\(resourceID)"
    }
}
