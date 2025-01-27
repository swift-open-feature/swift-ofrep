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
import HTTPTypes
import OFREP
import OpenAPIRuntime
import OpenFeature
import ServiceLifecycle
import Testing

@testable import Logging

@Suite("OFREP Provider")
final class OFREPProviderTests {
    init() {
        LoggingSystem.bootstrapInternal { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .debug
            return handler
        }
    }

    deinit {
        LoggingSystem.bootstrapInternal(SwiftLogNoOpLogHandler.init)
    }

    @Test("Returns default value when evaluation context serialization fails", arguments: [true, false])
    func returnsDefaultValueWhenEvaluationContextSerializationFails(defaultValue: Bool) async throws {
        struct TestError: Error, CustomStringConvertible {
            let description = "An error description."
        }

        struct Object: Codable, Sendable {
            func encode(to encoder: any Encoder) throws {
                throw TestError()
            }
        }

        let transport = FailingOFREPClientTransport()
        let provider = OFREPProvider(serverURL: URL(string: "http://stub.stub")!, transport: transport)

        let resolution = await provider.resolution(
            of: "flag",
            defaultValue: defaultValue,
            context: OpenFeatureEvaluationContext(fields: ["object": .object(Object())])
        )

        #expect(resolution.value == defaultValue)
        #expect(resolution.error == OpenFeatureResolutionError(code: .invalidContext, message: "An error description."))
        #expect(resolution.reason == .error)
    }

    @Test("Includes evaluation context in requests")
    func includesEvaluationContextInRequests() async throws {
        let serverURL = URL(string: "http://localhost:42")!
        let transport = RecordingOFREPClientTransport()
        let provider = OFREPProvider(serverURL: serverURL, transport: transport)
        let flag = "test-flag"
        let targetingKey = "test-targeting-key"

        struct Object: Codable, Sendable {
            let foo: String
        }
        let context = OpenFeatureEvaluationContext(
            targetingKey: targetingKey,
            fields: [
                "bool": true,
                "string": "foo",
                "int": 42,
                "double": 42.84,
                "date": .date(Date(timeIntervalSince1970: 42)),
                "object": .object(Object(foo: "bar")),
            ]
        )

        _ = await provider.resolution(of: flag, defaultValue: true, context: context)

        let request = try await #require(transport.requests.first)
        #expect(request.baseURL == serverURL)

        let body = try #require(request.body)
        let bodyBytes = try await Data(HTTPBody.ByteChunk(collecting: body, upTo: .max))
        let payload = Components.Schemas.EvaluationRequest(
            context: Components.Schemas.Context(
                targetingKey: targetingKey,
                additionalProperties: try OpenAPIObjectContainer(unvalidatedValue: [
                    "bool": true,
                    "string": "foo",
                    "int": 42,
                    "double": 42.84,
                    "date": 42,
                    "object": [
                        "foo": "bar"
                    ],
                ])
            )
        )
        try #expect(JSONDecoder().decode(Components.Schemas.EvaluationRequest.self, from: bodyBytes) == payload)
    }

    @Test("Returns successful server evaluation", arguments: [true, false])
    func returnsSuccessfulServerEvaluation(value: Bool) async throws {
        let transport = ClosureOFREPClientTransport {
            (
                HTTPResponse(status: .ok),
                HTTPBody(
                    """
                    {
                        "value": \(value),
                        "reason": "STATIC",
                        "variant": "a"
                    }
                    """
                )
            )
        }
        let provider = OFREPProvider(transport: transport)

        let resolution = await provider.resolution(of: "test-flag", defaultValue: !value, context: nil)

        #expect(resolution.value == value)
        #expect(resolution.error == nil)
        #expect(resolution.reason == .static)
        #expect(resolution.variant == "a")
    }

    @Test("Returns default value when transport fails", arguments: [true, false])
    func returnsDefaultValueWhenTransportFails(value: Bool) async throws {
        struct TransportError: Error, CustomStringConvertible {
            let description = "Example error."
        }
        let transport = ClosureOFREPClientTransport { throw TransportError() }
        let provider = OFREPProvider(transport: transport)

        let resolution = await provider.resolution(of: "test-flag", defaultValue: value, context: nil)

        #expect(resolution.value == value)
        #expect(resolution.error == OpenFeatureResolutionError(code: .general, message: "Example error."))
        #expect(resolution.reason == .error)
        #expect(resolution.variant == nil)
    }

    @Test("Graceful shutdown")
    func shutsDownTransport() async throws {
        /// A no-op service which is used to shut down the service group upon successful termination.
        struct ShutdownTrigger: Service, CustomStringConvertible {
            let description = "ShutdownTrigger"

            func run() async throws {}
        }

        let transport = RecordingOFREPClientTransport()
        let provider = OFREPProvider(transport: transport)

        await #expect(transport.numberOfShutdownCalls == 0)

        let group = ServiceGroup(
            configuration: .init(
                services: [
                    .init(service: provider),
                    .init(service: ShutdownTrigger(), successTerminationBehavior: .gracefullyShutdownGroup),
                ],
                logger: Logger(label: "test")
            )
        )

        try await group.run()

        await #expect(transport.numberOfShutdownCalls == 1)
    }
}

// MARK: - Helpers

private actor RecordingOFREPClientTransport: OFREPClientTransport {
    var requests = [Request]()
    var numberOfShutdownCalls = 0

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (
        HTTPResponse,
        HTTPBody?
    ) {
        requests.append(Request(body: body, baseURL: baseURL))
        return (HTTPResponse(status: 501), nil)
    }

    func shutdownGracefully() async throws {
        numberOfShutdownCalls += 1
    }

    struct Request {
        let body: HTTPBody?
        let baseURL: URL
    }
}

extension OFREPProvider<RecordingOFREPClientTransport> {
    fileprivate init(transport: Transport) {
        self.init(serverURL: .stub, transport: transport)
    }
}

private struct FailingOFREPClientTransport: OFREPClientTransport {
    private let sourceLocation: SourceLocation

    init(sourceLocation: SourceLocation = #_sourceLocation) {
        self.sourceLocation = sourceLocation
    }

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (
        HTTPResponse,
        HTTPBody?
    ) {
        Issue.record("Unexpectedly sent request to OFREP client transport.", sourceLocation: sourceLocation)
        throw TransportError()
    }

    func shutdownGracefully() async throws {
        Issue.record("Unexpectedly shut down OFREP client transport.", sourceLocation: sourceLocation)
        throw TransportError()
    }

    struct TransportError: Error {}
}

private struct ClosureOFREPClientTransport: OFREPClientTransport {
    private let sourceLocation: SourceLocation
    private let onRequest: @Sendable () async throws -> (HTTPResponse, HTTPBody?)

    init(
        sourceLocation: SourceLocation = #_sourceLocation,
        onRequest: @escaping @Sendable () async throws -> (HTTPResponse, HTTPBody?)
    ) {
        self.sourceLocation = sourceLocation
        self.onRequest = onRequest
    }

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (
        HTTPResponse,
        HTTPBody?
    ) {
        try await onRequest()
    }

    func shutdownGracefully() async throws {
        Issue.record("Unexpectedly shut down OFREP client transport.", sourceLocation: sourceLocation)
        throw TransportError()
    }

    struct TransportError: Error {}
}

extension OFREPProvider<ClosureOFREPClientTransport> {
    fileprivate init(transport: Transport) {
        self.init(serverURL: .stub, transport: transport)
    }
}

extension URL {
    fileprivate static let stub = URL(string: "http://stub.stub")!
}
