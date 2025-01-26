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

import Logging
import OpenFeature
import ServiceLifecycle

public struct OFREPProvider<Transport: OFREPClientTransport>: OpenFeatureProvider, CustomStringConvertible {
    public let metadata = OpenFeatureProviderMetadata(name: "OpenFeature Remote Evaluation Protocol Provider")
    public let description = "OFREPProvider"
    private let transport: Transport
    private let logger = Logger(label: "OFREPProvider")

    package init(transport: Transport) {
        self.transport = transport
    }

    public func resolution(
        of flag: String,
        defaultValue: Bool,
        context: OpenFeatureEvaluationContext?
    ) async -> OpenFeatureResolution<Bool> {
        OpenFeatureResolution(value: defaultValue)
    }

    public func run() async throws {
        try await gracefulShutdown()
        logger.debug("Shutting down.")
        try await transport.shutdownGracefully()
        logger.debug("Shut down.")
    }
}
