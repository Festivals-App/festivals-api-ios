//
//  Bundle+FramworkBundle.swift
//  EventusAPI-Swift
//
//  Created by Simon Gaus on 11.04.20.
//  Copyright © 2020 Simon Gaus. All rights reserved.
//

import Foundation

extension Bundle {
    var frameworkBundle: Bundle {
        return Bundle.init(identifier: "de.simonsserver.EventusAPI")!
    }
}
