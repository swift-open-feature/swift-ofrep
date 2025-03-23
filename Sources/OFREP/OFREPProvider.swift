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
import Logging
import OpenAPIRuntime
import OpenFeature
import ServiceLifecycle

public struct OFREPProvider<Transport: OFREPClientTransport>: OpenFeatureProvider, CustomStringConvertible {
    public let metadata = OpenFeatureProviderMetadata(name: "OpenFeature Remote Evaluation Protocol Provider")
    public let description = "OFREPProvider"
    private let transport: Transport
    private let client: Client
    private let logger = Logger(label: "OFREPProvider")

    package init(serverURL: URL, transport: Transport) {
        self.transport = transport
        self.client = Client(serverURL: serverURL, transport: transport)
    }

    public func resolution(
        of flag: String,
        defaultValue: Bool,
        context: OpenFeatureEvaluationContext?
    ) async -> OpenFeatureResolution<Bool> {
        await resolution(of: flag, defaultValue: defaultValue, context: context) { output in
            OpenFeatureResolution(output, defaultValue: defaultValue)
        }
    }

    public func resolution(
        of flag: String,
        defaultValue: String,
        context: OpenFeatureEvaluationContext?
    ) async -> OpenFeatureResolution<String> {
        await resolution(of: flag, defaultValue: defaultValue, context: context) { output in
            OpenFeatureResolution(output, defaultValue: defaultValue)
        }
    }

    public func resolution(
        of flag: String,
        defaultValue: Int,
        context: OpenFeature.OpenFeatureEvaluationContext?
    ) async -> OpenFeature.OpenFeatureResolution<Int> {
        await resolution(of: flag, defaultValue: defaultValue, context: context) { output in
            OpenFeatureResolution(output, defaultValue: defaultValue)
        }
    }

    public func resolution(
        of flag: String,
        defaultValue: Double,
        context: OpenFeature.OpenFeatureEvaluationContext?
    ) async -> OpenFeature.OpenFeatureResolution<Double> {
        await resolution(of: flag, defaultValue: defaultValue, context: context) { output in
            OpenFeatureResolution(output, defaultValue: defaultValue)
        }
    }

    public func run() async throws {
        try await gracefulShutdown()
        logger.debug("Shutting down.")
        try await transport.shutdownGracefully()
        logger.debug("Shut down.")
    }

    private func resolution<Value: OpenFeatureValue>(
        of flag: String,
        defaultValue: Value,
        context: OpenFeatureEvaluationContext?,
        transformServerResponse: (Operations.EvaluateFlag.Output) -> OpenFeatureResolution<Value>
    ) async -> OpenFeatureResolution<Value> {
        let request: Components.Schemas.EvaluationRequest
        do {
            request = try Components.Schemas.EvaluationRequest(flag: flag, defaultValue: defaultValue, context: context)
        } catch {
            return error.resolution
        }

        do {
            do {
                let response = try await client.evaluateFlag(
                    path: .init(key: flag),
                    headers: .init(accept: [.init(contentType: .json)]),
                    body: .json(request)
                )
                return transformServerResponse(response)
            } catch let error as ClientError {
                throw error.underlyingError
            }
        } catch {
            return OpenFeatureResolution(
                value: defaultValue,
                error: OpenFeatureResolutionError(code: .general, message: "\(error)"),
                reason: .error
            )
        }
    }
}
