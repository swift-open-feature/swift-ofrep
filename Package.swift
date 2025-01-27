// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "swift-ofrep",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "OFREP", targets: ["OFREP"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-open-feature/swift-open-feature.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.7.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-async-http-client.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "OFREP",
            dependencies: [
                .product(name: "OpenFeature", package: "swift-open-feature"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
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
