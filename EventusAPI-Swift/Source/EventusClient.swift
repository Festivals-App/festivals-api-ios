//
//  EventusClient.swift
//  EventusAPI-Swift
//
//  Created by Simon Gaus on 18.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

class EventusClient {
    
    /// The webservice to use.
    var webservice: Webservice
    
    /// The object handler to access festival objects.
    lazy var festivalHandler = FestivalHandler.init(with: self.webservice)
    
    /// The object handler to access artist objects.
    lazy var artistHandler = ArtistHandler.init(with: self.webservice)
    
    /// The object handler to access location objects.
    lazy var locationHandler = LocationHandler.init(with: self.webservice)
    
    /// The object handler to access event objects.
    lazy var eventHandler = EventHandler.init(with: self.webservice)
    
    /// The object handler to access image objects.
    lazy var imageHandler = ImageRefHandler.init(with: self.webservice)
    
    /// The object handler to access tag objects.
    lazy var tagHandler = TagHandler.init(with: self.webservice)
    
    /// The object handler to access place objects.
    lazy var placeHandler = PlaceHandler.init(with: self.webservice)
    
    /// The object handler to access link objects.
    lazy var linkHandler = LinkHandler.init(with: self.webservice)
    
    /// Initilizes the Eventus client object.
    /// - Parameters:
    ///     - apiKey: The API key used for making requests.
    ///     - apiVersion: The API version used for making requests.
    ///     - baseURL: The base URL used for making request.
    init(apiKey: String, apiVersion: String, baseURL: URL) {
        
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = ["Api-Key": apiKey]
        let session = URLSession.init(configuration: config)
        self.webservice =  Webservice.init(baseURL: baseURL, session: session, apiVersion: "")
    }
}
