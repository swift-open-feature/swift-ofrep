// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "swift-ofrep-integration-tests",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(path: "../")
    ],
    targets: [
        .testTarget(
            name: "Integration",
            dependencies: [
                .product(name: "OFREP", package: "swift-ofrep")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
