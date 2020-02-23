// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lastfm-api-swift",
    platforms: [.macOS(.v10_11), .iOS(.v10), .tvOS(.v9), .watchOS(.v3)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "lastfm-api-swift", targets: ["lastfm-api-swift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "4.9.1")),
        .package(url: "https://github.com/RxSwiftCommunity/RxAlamofire.git", .upToNextMajor(from: "5.0.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "lastfm-api-swift",
            dependencies: ["RxSwift", "Alamofire", "RxAlamofire"]),
        .testTarget(
            name: "lastfm-api-swiftTests",
            dependencies: ["lastfm-api-swift", "RxBlocking", "RxTest"]),
    ]
)
