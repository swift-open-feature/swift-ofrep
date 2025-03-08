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

import API
import AsyncHTTPClient
import Foundation
import Hummingbird
import Logging
import OFREP
import OTLPGRPC
import OTel
import OpenFeature
import OpenFeatureTracing
import ServiceLifecycle
import Tracing

@main
enum CTL {
    static func main() async throws {
        let logger = bootstrappedLogger()
        let tracer = try await bootstrappedTracer()
        let provider = bootstrappedProvider(logger: logger)

        let router = Router(context: APIRequestContext.self)
        router.middlewares.add(TracingMiddleware())
        let api = APIService(router: router)

        let group = ServiceGroup(
            services: [tracer, provider, api],
            gracefulShutdownSignals: [.sigint, .sigterm],
            logger: logger
        )

        try await group.run()
    }

    private static func bootstrappedLogger() -> Logger {
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .trace
            return handler
        }
        return Logger(label: "server")
    }

    private static func bootstrappedTracer() async throws -> some Service {
        let environment = OTelEnvironment.detected()
        let resource = await OTelResourceDetection(detectors: [
            OTelEnvironmentResourceDetector(environment: environment),
            OTelProcessResourceDetector(),
            .manual(OTelResource(attributes: ["service.name": "server"])),
        ]).resource(environment: environment)
        let exporter = OTLPGRPCSpanExporter(
            configuration: try OTLPGRPCSpanExporterConfiguration(environment: environment)
        )
        let processor = OTelBatchSpanProcessor(
            exporter: exporter,
            configuration: OTelBatchSpanProcessorConfiguration(environment: environment)
        )
        let tracer = OTelTracer(
            idGenerator: OTelRandomIDGenerator(),
            sampler: OTelParentBasedSampler(rootSampler: OTelConstantSampler(isOn: true)),
            propagator: OTelW3CPropagator(),
            processor: processor,
            environment: environment,
            resource: resource
        )
        InstrumentationSystem.bootstrap(tracer)
        return tracer
    }

    private static func bootstrappedProvider(logger: Logger) -> some Service {
        let ofrepProviderURL = ProcessInfo.processInfo.environment["OFREP_PROVIDER_URL"] ?? "http://localhost:8016"
        logger.info("Detected OFREP provider URL.", metadata: ["url": "\(ofrepProviderURL)"])

        let provider = OFREPProvider(serverURL: URL(string: ofrepProviderURL)!)
        OpenFeatureSystem.addHooks([OpenFeatureTracingHook(setSpanStatusOnError: true, recordTargetingKey: true)])
        OpenFeatureSystem.setProvider(provider)
        return provider
    }
}
