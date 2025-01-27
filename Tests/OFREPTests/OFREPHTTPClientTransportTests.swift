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

import AsyncHTTPClient
import Foundation
import Logging
import NIOCore
import OFREP
import ServiceLifecycle
import Testing

@testable import OpenAPIAsyncHTTPClient

@Suite("HTTP Client Transport")
struct OFREPHTTPClientTransportTests {
    @Test("Defaults to shared HTTP client")
    func sharedHTTPClient() async throws {
        let provider = OFREPProvider(serverURL: .stub)

        let serviceGroup = ServiceGroup(
            configuration: .init(
                services: [.init(service: provider), .shutdownTrigger],
                logger: Logger(label: "test")
            )
        )

        try await serviceGroup.run()
    }

    @Test("Shuts down internally created HTTP client")
    func internallyCreatedHTTPClient() async throws {
        let provider = OFREPProvider(serverURL: .stub, configuration: HTTPClient.Configuration())

        let serviceGroup = ServiceGroup(
            configuration: .init(
                services: [.init(service: provider), .shutdownTrigger],
                logger: Logger(label: "test")
            )
        )

        try await serviceGroup.run()
    }

    @Test("Forwards request to AsyncHTTPClientTransport")
    func forwardsRequest() async throws {
        let requestSender = RecordingRequestSender()
        let transport = AsyncHTTPClientTransport(configuration: .init(), requestSender: requestSender)
        let provider = OFREPProvider(serverURL: .stub, transport: transport)

        _ = await provider.resolution(of: "flag", defaultValue: false, context: nil)

        await #expect(requestSender.requests.count == 1)
    }
}

private actor RecordingRequestSender: HTTPRequestSending {
    var requests = [Request]()

    func send(
        request: HTTPClientRequest,
        with client: HTTPClient,
        timeout: TimeAmount
    ) async throws -> AsyncHTTPClientTransport.Response {
        requests.append(Request(request: request, client: client, timeout: timeout))
        return HTTPClientResponse()
    }

    struct Request {
        let request: HTTPClientRequest
        let client: HTTPClient
        let timeout: TimeAmount
    }
}
