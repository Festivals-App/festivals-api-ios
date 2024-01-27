<p align="center">
    <a href="https://github.com/festivals-app/festivals-api-ios/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/festivals-app/festivals-api-ios?style=flat"></a>
    <a href="https://github.com/festivals-app/festivals-api-ios/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/festivals-app/festivals-api-ios?style=flat"></a>
    <a href="./LICENSE" title="License"><img src="https://img.shields.io/github/license/festivals-app/festivals-api-ios.svg"></a>
</p>

<h1 align="center">
    <br/><br/>
    FestivalsAPI client library
    <br/><br/>
</h1>

A client library that implements the complete FestivalsAPI feature set and makes coding against it super easy.

![Figure 1: Architecture Overview Highlighted](https://github.com/Festivals-App/festivals-documentation/blob/main/images/architecture/overview_api_ios.png "Figure 1: Architecture Overview Highlighted")

<hr/>
<p align="center">
  <a href="#development">Development</a> •
  <a href="#usage">Usage</a> •
  <a href="#installation">Installation</a> •
  <a href="#engage">Engage</a>
</p>
<hr/>

## Development
The FestivalsAPI client library is tightly coupled with the [festivals-server](https://github.com/Festivals-App/festivals-server) which provides the implementation of the [FestivalsAPI](https://github.com/Festivals-App/festivals-server/blob/main/DOCUMENTATION.md) and is also coupled with the [festivals-identity-server](https://github.com/Festivals-App/festivals-identity-server) which provides means to authenticate and authorize against the FestivalsAPI. To find out more about the architecture and technical information see the [ARCHITECTURE](./ARCHITECTURE.md) document. The general documentation for the Festivals App is in the [festivals-documentation](https://github.com/festivals-app/festivals-documentation) repository. The documentation repository contains architecture information, general deployment documentation, templates and other helpful documents.

The client library is the optimal starting point to implement new [FestivalsApp](https://github.com/Festivals-App/festivals-app-ios) behaviour.

#### Requirements
-  [Xcode](https://apps.apple.com/de/app/xcode/id497799835) Version 15.2+
-  [jazzy](https://github.com/realm/jazzy) 0.14.4+ for building the documentation
-  [bartycrouch](https://github.com/Flinesoft/BartyCrouch) 4.15.0+ for string localization
   
#### ExampleApp
There is an [ExampleApp](https://github.com/Festivals-App/festivals-api-ios/tree/master/ExampleApp) for developing and testing.
    
#### Testing
The unit tests are implemented via the XCTest framework. To run the tests successfully you need to provide a valid address to a testable FestivalsAPI instance in the Info.plist under the `FestivalsAPI_URL` key. To setup the FestivalsAPI see the [festivals-server](https://github.com/Festivals-App/festivals-server) repository. At the moment the tests are run manually, i want to run the tests automated but i need to decided on the automation/CI which should be used.

## Usage
The library consists of the `FestivalsClient` class, the handler classes and their corresponding objects.

- **Objects**: Festival, Event, Artist, Location, ImageRef, Link, Place, Tag
- **Handler**: FestivalHandler, EventHandler, ArtistHandler, LocationHandler, ImageRefHandler, LinkHandler, PlaceHandler and TagHandler

To use this library, create an `FestivalsClient` object by calling the `init(baseURL:clientAuth:)` function. The client object provides you with a handler for each object type provided by the FestivalsAPI, through which you can fetch, create and delete those objects.

```swift
// Create the handler
let clientAuth = IdentityAndTrust(certData:<#certData#><##>, CAData:<#caData#>, certPassword: <#Password#>, apiKey:<#apiKey#>)
let client = FestivalsClient(baseURL: <#baseURL#>, clientAuth: <#IdentityAndTrust#>)

// fetch all festivals
client.festivalHandler.all { (festivals, err) in
    guard let festivals = festivals else {
        print(err)
        return
    }
    // use festivals
}
```

## Installation
The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the swift compiler.
Once you have your Swift package set up, adding FestivalsAPI as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```ogdl
dependencies: [
    .package(url: "https://github.com/Festivals-App/festivals-api-ios.git", .upToNextMajor(from: "0.3"))
]
```

## Engage
I welcome every contribution, whether it is a pull request or a fixed typo. The best place to discuss questions and suggestions regarding the FestivalsAPI iOS client library is the projects [issues](https://github.com/Festivals-App/festivals-api-ios/issues) section. More general information and a good starting point if you want to get involved is the [festival-documentation](https://github.com/Festivals-App/festivals-documentation) repository.

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/festivals-app/festivals-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/festivals-app/festivals-documentation/question.svg?style=flat-square"></a> </a>   |
| **Other Requests**    | <a href="mailto:simon.cay.gaus@gmail.com" title="Email me"><img src="https://img.shields.io/badge/email-Simon-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

#### Licensing
Copyright (c) 2020-2024 Simon Gaus. Licensed under the [**GNU Lesser General Public License v3.0**](./LICENSE)
