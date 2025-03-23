//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift OpenFeature open source project
//
// Copyright (c) 2025 the Swift OpenFeature project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation
import OFREP
import OpenFeature
import ServiceLifecycle
import Testing

@testable import Logging

@Suite("OFREP Integration Tests")
struct OFREPIntegrationTests {
    @Suite("Bool Flag Resolution")
    struct BoolResolutionTests {
        @Test("Static", arguments: [("static-on", true), ("static-off", false)])
        func staticBool(flag: String, expectedValue: Bool) async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: expectedValue,
                    error: nil,
                    reason: .static,
                    variant: expectedValue ? "on" : "off",
                    flagMetadata: [:]
                )
                await #expect(provider.resolution(of: flag, defaultValue: !expectedValue, context: nil) == resolution)
            }
        }

        @Test("Targeting Match")
        func targetingMatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: true,
                    error: nil,
                    reason: .targetingMatch,
                    variant: "on",
                    flagMetadata: [:]
                )
                let flag = "targeting-on"
                let context = OpenFeatureEvaluationContext(targetingKey: "swift")
                await #expect(provider.resolution(of: flag, defaultValue: false, context: context) == resolution)
            }
        }

        @Test("No Targeting Match")
        func noTargetingMatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: false,
                    error: nil,
                    reason: .default,
                    variant: "off",
                    flagMetadata: [:]
                )
                let flag = "targeting-on"
                await #expect(provider.resolution(of: flag, defaultValue: true, context: nil) == resolution)
            }
        }

        @Test("Type mismatch", arguments: [true, false])
        func typeMismatch(defaultValue: Bool) async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: defaultValue,
                    error: OpenFeatureResolutionError(
                        code: .typeMismatch,
                        message: #"Expected flag value of type "Bool" but received "String"."#
                    ),
                    reason: .error,
                    variant: "a"
                )
                let flag = "static-a"
                await #expect(provider.resolution(of: flag, defaultValue: defaultValue, context: nil) == resolution)
            }
        }
    }

    @Suite("String Flag Resolution")
    struct StringResolutionTests {
        @Test("Static", arguments: [("static-a", "a", "value-a"), ("static-b", "b", "value-b")])
        func staticBool(flag: String, variant: String, expectedValue: String) async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: expectedValue,
                    error: nil,
                    reason: .static,
                    variant: variant,
                    flagMetadata: [:]
                )
                await #expect(provider.resolution(of: flag, defaultValue: "default", context: nil) == resolution)
            }
        }

        @Test("Targeting Match")
        func targetingMatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: "value-b",
                    error: nil,
                    reason: .targetingMatch,
                    variant: "b",
                    flagMetadata: [:]
                )
                let flag = "targeting-b"
                let context = OpenFeatureEvaluationContext(targetingKey: "swift")
                await #expect(provider.resolution(of: flag, defaultValue: "default", context: context) == resolution)
            }
        }

        @Test("No Targeting Match")
        func noTargetingMatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: "value-a",
                    error: nil,
                    reason: .default,
                    variant: "a",
                    flagMetadata: [:]
                )
                let flag = "targeting-b"
                await #expect(provider.resolution(of: flag, defaultValue: "default", context: nil) == resolution)
            }
        }

        @Test("Type mismatch")
        func typeMismatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: "default",
                    error: OpenFeatureResolutionError(
                        code: .typeMismatch,
                        message: #"Expected flag value of type "String" but received "Bool"."#
                    ),
                    reason: .error,
                    variant: "on"
                )
                let flag = "static-on"
                await #expect(provider.resolution(of: flag, defaultValue: "default", context: nil) == resolution)
            }
        }
    }

    @Suite("Int Flag Resolution")
    struct IntResolutionTests {
        @Test("Static", arguments: [("static-negative-42", "a", -42), ("static-positive-42", "b", 42)])
        func staticBool(flag: String, variant: String, expectedValue: Int) async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: expectedValue,
                    error: nil,
                    reason: .static,
                    variant: variant,
                    flagMetadata: [:]
                )
                await #expect(provider.resolution(of: flag, defaultValue: 0, context: nil) == resolution)
            }
        }

        @Test("Targeting Match")
        func targetingMatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: 42,
                    error: nil,
                    reason: .targetingMatch,
                    variant: "b",
                    flagMetadata: [:]
                )
                let flag = "targeting-42"
                let context = OpenFeatureEvaluationContext(targetingKey: "swift")
                await #expect(provider.resolution(of: flag, defaultValue: 0, context: context) == resolution)
            }
        }

        @Test("No Targeting Match")
        func noTargetingMatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: -42,
                    error: nil,
                    reason: .default,
                    variant: "a",
                    flagMetadata: [:]
                )
                let flag = "targeting-42"
                await #expect(provider.resolution(of: flag, defaultValue: 0, context: nil) == resolution)
            }
        }

        @Test("Type mismatch")
        func typeMismatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: 42,
                    error: OpenFeatureResolutionError(
                        code: .typeMismatch,
                        message: #"Expected flag value of type "Int" but received "String"."#
                    ),
                    reason: .error,
                    variant: "a"
                )
                let flag = "static-a"
                await #expect(provider.resolution(of: flag, defaultValue: 42, context: nil) == resolution)
            }
        }
    }

    @Suite("Double Flag Resolution")
    struct DoubleResolutionTests {
        @Test("Static", arguments: [("static-negative-42.123", "a", -42.123), ("static-positive-42.123", "b", 42.123)])
        func staticBool(flag: String, variant: String, expectedValue: Double) async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: expectedValue,
                    error: nil,
                    reason: .static,
                    variant: variant,
                    flagMetadata: [:]
                )
                await #expect(provider.resolution(of: flag, defaultValue: 0.0, context: nil) == resolution)
            }
        }

        @Test("Targeting Match")
        func targetingMatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: 42.123,
                    error: nil,
                    reason: .targetingMatch,
                    variant: "b",
                    flagMetadata: [:]
                )
                let flag = "targeting-42.123"
                let context = OpenFeatureEvaluationContext(targetingKey: "swift")
                await #expect(provider.resolution(of: flag, defaultValue: 0.0, context: context) == resolution)
            }
        }

        @Test("No Targeting Match")
        func noTargetingMatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: -42.123,
                    error: nil,
                    reason: .default,
                    variant: "a",
                    flagMetadata: [:]
                )
                let flag = "targeting-42.123"
                await #expect(provider.resolution(of: flag, defaultValue: 0.0, context: nil) == resolution)
            }
        }

        @Test("Type mismatch")
        func typeMismatch() async throws {
            let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

            try await withOFREPProvider(provider) {
                let resolution = OpenFeatureResolution(
                    value: 42.123,
                    error: OpenFeatureResolutionError(
                        code: .typeMismatch,
                        message: #"Expected flag value of type "Double" but received "String"."#
                    ),
                    reason: .error,
                    variant: "a"
                )
                let flag = "static-a"
                await #expect(provider.resolution(of: flag, defaultValue: 42.123, context: nil) == resolution)
            }
        }
    }

    @Test("Flag not found", arguments: [true, false])
    func flagNotFound(defaultValue: Bool) async throws {
        let provider = OFREPProvider(serverURL: URL(string: "http://localhost:8016")!)

        try await withOFREPProvider(provider) {
            let resolution = OpenFeatureResolution(
                value: defaultValue,
                error: OpenFeatureResolutionError(code: .flagNotFound, message: "flag `💩` does not exist"),
                reason: .error
            )
            await #expect(provider.resolution(of: "💩", defaultValue: defaultValue, context: nil) == resolution)
        }
    }
}

private func withOFREPProvider<Transport: OFREPClientTransport>(
    _ provider: OFREPProvider<Transport>,
    perform integrationTest: @escaping @Sendable () async throws -> Void
) async throws {
    let integrationTestService = IntegrationTestService(test: integrationTest)
    let group = ServiceGroup(
        configuration: ServiceGroupConfiguration(
            services: [
                .init(service: provider),
                .init(service: integrationTestService, successTerminationBehavior: .gracefullyShutdownGroup),
            ],
            logger: Logger(label: #function)
        )
    )

    try await group.run()
}

private struct IntegrationTestService: Service {
    let test: @Sendable () async throws -> Void

    func run() async throws {
        try await test()
    }
}
