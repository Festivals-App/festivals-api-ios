<h1 align="center">
FestivalsAPI client library for iOS
</h1>

<p align="center">
    <a href="https://github.com/Carthage/Carthage" title="License"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
   <a href="https://github.com/festivals-app/festivals-api-ios/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/festivals-app/festivals-api-ios?style=flat"></a>
   <a href="https://github.com/festivals-app/festivals-api-ios/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/festivals-app/festivals-api-ios?style=flat"></a>
   <a href="./LICENSE" title="License"><img src="https://img.shields.io/github/license/festivals-app/festivals-api-ios.svg"></a>
</p>

<p align="center">
  <a href="#development">Development</a> •
  <a href="#usage">Usage</a> •
  <a href="#installation">Installation</a> •
  <a href="#engage">Engage</a> •
  <a href="#licensing">Licensing</a>
</p>

The framework is designed to make interacting with the Festivals API seamless and efficient. Downloading festivals, artists and other objects to your app is all made easy with FestivalsAPI's components. 

## Development

TBA

### Requirements

- iOS 13.1+
- Xcode 12.4.1+
- swift-tools-version:5.3+
- [jazzy](https://github.com/realm/jazzy) 0.13.6+ (for building the documentation)

## Usage

TBA

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

### Documentation

The full documentation for the Festivals App is in the [festivals-documentation](https://github.com/festivals-app/festivals-documentation) repository. The documentation repository contains technical documents, architecture information, UI/UX specifications, and whitepapers related to this implementation.

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

### Manually

If you prefer not to use Carthage, you can integrate FestivalsAPI into your project manually.
You only need to build and add the FestivalsAPI framework (FestivalsAPI.framework) to your project. 

## Engage

TBA

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/festivals-app/festivals-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/festivals-app/festivals-documentation/question.svg?style=flat-square"></a> </a>   |
| **Concept Feedback**    | <a href="https://github.com/festivals-app/festivals-documentation/issues/new/choose" title="Open Concept Feedback"><img src="https://img.shields.io/github/issues/festivals-app/festivals-documentation/architecture.svg?style=flat-square"></a>  |
| **Other Requests**    | <a href="mailto:phisto05@gmail.com" title="Email Festivals Team"><img src="https://img.shields.io/badge/email-Festivals%20team-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

## Licensing

Copyright (c) 2020 Simon Gaus.

Licensed under the **GNU Lesser General Public License v3.0** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.html.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
