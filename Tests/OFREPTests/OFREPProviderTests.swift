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
import Testing
import ServiceLifecycle
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

private actor RecordingOFREPClientTransport: OFREPClientTransport {
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
        (HTTPResponse(status: 418), nil)
    }

    func shutdownGracefully() async throws {
        numberOfShutdownCalls += 1
    }
}
