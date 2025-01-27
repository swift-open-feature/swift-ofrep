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
import HTTPTypes
import Logging
import NIOCore
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime

struct OFREPHTTPClientTransport: OFREPClientTransport {
    let transport: AsyncHTTPClientTransport
    let shouldShutDownHTTPClient: Bool

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (
        HTTPResponse,
        HTTPBody?
    ) {
        try await transport.send(request, body: body, baseURL: baseURL, operationID: operationID)
    }

    func shutdownGracefully() async throws {
        guard shouldShutDownHTTPClient else { return }
        try await transport.configuration.client.shutdown()
    }

    static let loggingDisabled = Logger(label: "OFREP-do-not-log", factory: { _ in SwiftLogNoOpLogHandler() })
}

extension OFREPProvider<OFREPHTTPClientTransport> {
    public init(serverURL: URL, httpClient: HTTPClient = .shared, timeout: Duration = .seconds(60)) {
        self.init(
            serverURL: serverURL,
            transport: AsyncHTTPClientTransport(
                configuration: AsyncHTTPClientTransport.Configuration(
                    client: httpClient,
                    timeout: TimeAmount(timeout)
                )
            )
        )
    }

    public init(
        serverURL: URL,
        configuration: HTTPClient.Configuration,
        eventLoopGroup: EventLoopGroup = HTTPClient.defaultEventLoopGroup,
        backgroundActivityLogger: Logger? = nil,
        timeout: Duration = .seconds(60)
    ) {
        let httpClient = HTTPClient(
            eventLoopGroupProvider: .shared(eventLoopGroup),
            configuration: configuration,
            backgroundActivityLogger: backgroundActivityLogger ?? OFREPHTTPClientTransport.loggingDisabled
        )
        let httpClientTransport = AsyncHTTPClientTransport(
            configuration: AsyncHTTPClientTransport.Configuration(
                client: httpClient,
                timeout: TimeAmount(timeout)
            )
        )
        self.init(
            serverURL: serverURL,
            transport: OFREPHTTPClientTransport(transport: httpClientTransport, shouldShutDownHTTPClient: true)
        )
    }

    package init(serverURL: URL, transport: AsyncHTTPClientTransport) {
        self.init(
            serverURL: serverURL,
            transport: OFREPHTTPClientTransport(transport: transport, shouldShutDownHTTPClient: false)
        )
    }
}
