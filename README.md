<h1 align="center">
FestivalsAPI client library for iOS
</h1>

<p align="center">
    <a href="https://github.com/festivals-app/festivals-api-ios/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/festivals-app/festivals-api-ios?style=flat"></a>
    <a href="https://github.com/festivals-app/festivals-api-ios/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/festivals-app/festivals-api-ios?style=flat"></a>
    <a href="https://github.com/Carthage/Carthage" title="License"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
    <a href="./LICENSE" title="License"><img src="https://img.shields.io/github/license/festivals-app/festivals-api-ios.svg"></a>
</p>

<p align="center">
  <a href="#development">Development</a> •
  <a href="#usage">Usage</a> •
  <a href="#installation">Installation</a> •
  <a href="#engage">Engage</a> •
  <a href="#licensing">Licensing</a>
</p>

The library is designed to make interacting with the FestivalsAPI seamless and efficient. Downloading festivals, artists and other objects to your app is all made easy with its components.

## Development

### Setup

1. Install and setup Xcode 13.1 or higher
2. Install jazzy
   ```console
   brew install jazzy
   ```
3. Install bartycrouch
   ```console
   brew install bartycrouch
   ```
   
### Build
    
There is an [ExampleApp](https://github.com/Festivals-App/festivals-api-ios/blob/main/ExampleApp) for developing and testing which you can build using Xcode.
    
### Requirements

-  iOS 13.0+
-  Xcode 13.1+
-  swift-tools-version:5.3+
-  [jazzy](https://github.com/realm/jazzy) 0.13.6+ for building the documentation
-  [bartycrouch](https://github.com/Flinesoft/BartyCrouch) 4.8.0+ for string localization

## Usage

To use the 

```swift
// Create the handler
let client = FestivalsClient(apiKey: <#API Key#>, apiVersion: .v0_1, baseURL: <#API URL#>)

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

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate FestivalsAPI into your Xcode project using Carthage, specify it in your Cartfilee:

```ogdl
github "https://github.com/Phisto/FestivalsAPI-Swift" ~> 0.1
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding FestivalsAPI as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```ogdl
dependencies: [
.package(url: "https://github.com/Phisto/FestivalsAPI-Swift.git", .upToNextMajor(from: "0.1"))
]
```

## Architecture

![Figure 1: Architecture Overview Highlighted](https://github.com/Festivals-App/festivals-documentation/blob/main/images/architecture/overview_api_ios.png "Figure 1: Architecture Overview Highlighted")

The FestivalsAPI client library is tightly coupled with the [festivals-server](https://github.com/Festivals-App/festivals-server) which provides the implementation of the FestivalsAPI and is also coupled with the [festivals-identity-server](https://github.com/Festivals-App/festivals-identity-server) which provides means to authenticate and authorize against the FestivalsAPI. It is used by the [festivals-app-ios](https://github.com/Festivals-App/festivals-app-ios) and the [festivals-creator-app](https://github.com/Festivals-App/festivals-creator-app) and should be consumable by any of apples major device platforms. To find out more about architecture and technical information see the [ARCHITECTURE](./ARCHITECTURE.md) document.

The client library is the optimal starting point to implement new festival behaviour.

The full documentation for the FestivalsApp is in the [festivals-documentation](https://github.com/festivals-app/festivals-documentation) repository. The documentation repository contains technical documents, architecture information, UI/UX specifications, and whitepapers related to this implementation.

## Engage

I welcome every contribution, whether it is a pull request or a fixed typo. The best place to discuss questions and suggestions regarding the FestivalsAPI iOS client library is the projects [issues](https://github.com/Festivals-App/festivals-api-ios/issues) section. More general information and a good starting point if you want to get involved is the [festival-documentation](https://github.com/Festivals-App/festivals-documentation) repository.

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/festivals-app/festivals-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/festivals-app/festivals-documentation/question.svg?style=flat-square"></a> </a>   |
| **Other Requests**    | <a href="mailto:simon.cay.gaus@gmail.com" title="Email me"><img src="https://img.shields.io/badge/email-Simon-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

## Licensing

Copyright (c) 2020 Simon Gaus.

Licensed under the **GNU Lesser General Public License v3.0** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.html.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
