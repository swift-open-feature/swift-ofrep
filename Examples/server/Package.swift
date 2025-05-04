// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "server",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "server", targets: ["CTL"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-distributed-tracing.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-otel/swift-otel.git", .upToNextMinor(from: "0.11.0")),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-auth.git", from: "2.0.0"),
        .package(url: "https://github.com/swift-open-feature/swift-open-feature.git", branch: "main"),
        .package(url: "https://github.com/swift-open-feature/swift-ofrep.git", branch: "main"),

        // override HTTP Client until Tracing PR is merged
        .package(url: "https://github.com/slashmo/async-http-client.git", branch: "feature/tracing"),
    ],
    targets: [
        .executableTarget(
            name: "CTL",
            dependencies: [
                .target(name: "API"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Tracing", package: "swift-distributed-tracing"),
                .product(name: "OTel", package: "swift-otel"),
                .product(name: "OTLPGRPC", package: "swift-otel"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "OpenFeature", package: "swift-open-feature"),
                .product(name: "OpenFeatureTracing", package: "swift-open-feature"),
                .product(name: "OFREP", package: "swift-ofrep"),
            ]
        ),
        .target(
            name: "API",
            dependencies: [
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HummingbirdAuth", package: "hummingbird-auth"),
                .product(name: "OpenFeature", package: "swift-open-feature"),
            ]
        ),
    ]
)
