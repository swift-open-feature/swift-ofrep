// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "swift-ofrep",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "OFREP", targets: ["OFREP"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-open-feature/swift-open-feature.git", branch: "main")
    ],
    targets: [
        .target(
            name: "OFREP",
            dependencies: [
                .product(name: "OpenFeature", package: "swift-open-feature")
            ]
        ),
        .testTarget(
            name: "OFREPTests",
            dependencies: [
                .target(name: "OFREP")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
