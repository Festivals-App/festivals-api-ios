# Festivals API client library for iOS and macOS

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Eventus web service, live and lightweight in your app.

## Overview

The EventusAPI framework is designed to make interacting with the Eventus web service seamless and efficient. Downloading festivals, artists and other objects to your app is all made easy with EventusAPI's components. 

## Requirements

- iOS 13.1+
- macOS 10.13+
- Xcode 11.4.1+
- [jazzy](https://github.com/realm/jazzy) 0.13.3+ (for building the documentation)

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate EventusAPI into your Xcode project using Carthage, specify it in your Cartfilee:

```ogdl
github "https://github.com/Phisto/EventusAPI-Swift" ~> 0.1
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding EventusAPI as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```ogdl
dependencies: [
.package(url: "https://github.com/Phisto/EventusAPI-Swift.git", .upToNextMajor(from: "0.1"))
]
```

### Manually

If you prefer not to use Carthage, you can integrate EventusAPI into your project manually.
You only need to build and add the EventusAPI framework (EventusAPI.framework) to your project. 

## Usage

```swift
// Create the handler
let handler = FestivalHandler.init(with: <#webservice#>)

// fetch all festivals
handler.all { (festivals, error) -> (Void) in
    guard let festivals = festivals else {
        print(error)
        return
    }
    
    // use festivals
}
```

