//
//  FestivalsClient.swift
//  FestivalsAPI
//
//  Created by Simon Gaus on 18.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

// MARK: APIError

/// The errors returned by the FestivalsAPI framework.
public enum APIError: Error {
    /// Returned if the request to the FestivalsAPI web service failed.
    case requestFailed
    /// Returned if the response from the FestivalsAPI web service could not be processed.
    case serviceError
    ///Returned if the received data could not be parsed into objects.
    case parsingFailed
    /// Returned if there was an unexpected error while making the request.
    case unknownError
    ///Returned if the request was successfull, but the requested record is not available.
    case recordDoesNotExist
}

// MARK: APIVersions

public enum APIVersion: String {
    case v0_1 = "0.1"
}

// MARK: FestivalsClient

/**

This class is the central entry point to the FestivalsAPI framework.

To ease code organisation and structuring the FestivalsAPI framework is split into different parts which correspond to an object type stored and manged by the FestivalsAPI web service. Through the corresponding object handler you have access to the objects, their associated objects and properties.

## Available object handler:

* `FestivalHandler` for accessing festival objects.
* `ArtistHandler` for accessing artist objects.
* `LocationHandler` for accessing location objects.
* `EventHandler` for accessing event objects.
* `ImageRefHandler` for accessing image objects.
* `TagHandler` for accessing tag objects.
* `PlaceHandler` for accessing place objects.
* `LinkHandler` for accessing link objects.

*/
public class FestivalsClient {
    
    /// The object handler to access festival objects.
    public lazy var festivalHandler = FestivalHandler.init(with: self.webservice)
    /// The object handler to access artist objects.
    public lazy var artistHandler = ArtistHandler.init(with: self.webservice)
    /// The object handler to access location objects.
    public lazy var locationHandler = LocationHandler.init(with: self.webservice)
    /// The object handler to access event objects.
    public lazy var eventHandler = EventHandler.init(with: self.webservice)
    /// The object handler to access image objects.
    public lazy var imageHandler = ImageRefHandler.init(with: self.webservice)
    /// The object handler to access tag objects.
    public lazy var tagHandler = TagHandler.init(with: self.webservice)
    /// The object handler to access place objects.
    public lazy var placeHandler = PlaceHandler.init(with: self.webservice)
    /// The object handler to access link objects.
    public lazy var linkHandler = LinkHandler.init(with: self.webservice)
    
    /// The webservice to use.
    private var webservice: Webservice
    
    /// Initilizes the FestivalsAPI client object.
    /// - Parameters:
    ///     - apiKey: The API key used for making requests.
    ///     - apiVersion: The API version used for making requests.
    ///     - baseURL: The base URL used for making request.
    public init(apiKey: String, apiVersion: APIVersion, baseURL: URL) {
        
        let session = URLSession.init(configuration: .ephemeral)
        self.webservice =  Webservice.init(baseURL: baseURL, session: session, apiKey: apiKey, apiVersion: .v0_1)
    }
}
