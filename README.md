[![bitrise CI](https://img.shields.io/bitrise/ec061cfdaf1d423d?token=zDQthUt8bAxUJo_SzmpS6w)](https://bitrise.io)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

# lastfm-api-swift

This package makes data from the last.fm api available via observables in Swift. 

## Usage

```
  let lastfm = LastFMApi(apiKey: apiKey)
  lastfm.info(artist: "Tame Impala")
      .subscribe(onNext: { (info) in
          print("Artist info: \(info)")
      })
      .disposed(by: bag)
```

## Requirements

* Xcode 11 or Swift Package Manager
* Swift 5.0

## Dependencies

lastfm-api-test depends on RxSwift, Alamofire and RxAlamofire. To use the library, you will need a last.fm api key.

## Testing

Unit tests are included. To run those, you have to set an environment variable for the last.fm api key. To run the tests from the command line, use the following command:
LASTFM_API_KEY=YOURKEY swift test

## Installation

Currently only build and usage via swift package manager is supported:

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

The easiest way to add the library is directly from within XCode (11). Alternatively you can create a `Package.swift` file. 

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "MyProject",
  dependencies: [
  .package(url: "https://github.com/katoemba/lastfm-api-swift.git", from: "0.0.1")
  ],
  targets: [
    .target(name: "MyProject", dependencies: ["lastfm-api-swift"])
  ]
)
```

