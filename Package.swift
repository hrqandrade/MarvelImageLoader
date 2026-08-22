// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MarvelImageLoader",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "MarvelImageLoader", targets: ["MarvelImageLoader"])
    ],
    targets: [
        .target(name: "MarvelImageLoader"),
        .testTarget(name: "MarvelImageLoaderTests", dependencies: ["MarvelImageLoader"])
    ]
)
