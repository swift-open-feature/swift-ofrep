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
import OpenAPIRuntime
import OpenFeature
import Testing

@Suite("Resolution Decoding")
struct OpenFeatureResolutionDecodingTests {
    @Suite("Bool")
    struct BoolResolutionDecodingTests {
        @Test("Success", arguments: [true, false])
        func success(value: Bool) {
            let response = Operations.PostOfrepV1EvaluateFlagsKey.Output.ok(
                .init(
                    body: .json(
                        Components.Schemas.ServerEvaluationSuccess(
                            value1: .init(
                                value1: .init(
                                    key: "flag",
                                    reason: "TARGETING_MATCH",
                                    variant: "b",
                                    metadata: .init(additionalProperties: ["foo": .case2("bar")])
                                ),
                                value2: .BooleanFlag(.init(value: value))
                            ),
                            value2: .init(cacheable: nil)
                        )
                    )
                )
            )

            let resolution = OpenFeatureResolution(
                value: value,
                error: nil,
                reason: .targetingMatch,
                variant: "b",
                flagMetadata: ["foo": .string("bar")]
            )

            #expect(OpenFeatureResolution(response, defaultValue: !value) == resolution)
        }

        @Test("Bad request", arguments: ["Targeting key is required.", nil])
        func badRequest(message: String?) {
            let response = Operations.PostOfrepV1EvaluateFlagsKey.Output.badRequest(
                .init(
                    body: .json(
                        .init(
                            key: "flag",
                            errorCode: .targetingKeyMissing,
                            errorDetails: message
                        )
                    )
                )
            )

            let resolution = OpenFeatureResolution(
                value: true,
                error: OpenFeatureResolutionError(code: .targetingKeyMissing, message: message),
                reason: .error
            )

            #expect(OpenFeatureResolution(response, defaultValue: true) == resolution)
        }

        @Test("Not found", arguments: ["Flag not found.", nil])
        func notFound(message: String?) {
            let response = Operations.PostOfrepV1EvaluateFlagsKey.Output.notFound(
                .init(
                    body: .json(
                        .init(
                            key: "flag",
                            errorCode: .flagNotFound,
                            errorDetails: message
                        )
                    )
                )
            )

            let resolution = OpenFeatureResolution(
                value: false,
                error: OpenFeatureResolutionError(code: .flagNotFound, message: message),
                reason: .error
            )

            #expect(OpenFeatureResolution(response, defaultValue: false) == resolution)
        }

        @Test("Unauthorized")
        func unauthorized() throws {
            let response = Operations.PostOfrepV1EvaluateFlagsKey.Output.unauthorized(.init())

            let resolution = OpenFeatureResolution(
                value: false,
                error: OpenFeatureResolutionError(code: .general, message: "Unauthorized."),
                reason: .error
            )

            #expect(OpenFeatureResolution(response, defaultValue: false) == resolution)
        }

        @Test("Forbidden")
        func forbidden() throws {
            let response = Operations.PostOfrepV1EvaluateFlagsKey.Output.forbidden(.init())

            let resolution = OpenFeatureResolution(
                value: false,
                error: OpenFeatureResolutionError(code: .general, message: "Forbidden."),
                reason: .error
            )

            #expect(OpenFeatureResolution(response, defaultValue: false) == resolution)
        }

        @Test("Too many requests without retry date")
        func tooManyRequests() throws {
            let response = Operations.PostOfrepV1EvaluateFlagsKey.Output.tooManyRequests(.init())

            let resolution = OpenFeatureResolution(
                value: false,
                error: OpenFeatureResolutionError(code: .general, message: "Too many requests."),
                reason: .error
            )

            #expect(OpenFeatureResolution(response, defaultValue: false) == resolution)
        }

        @Test("Too many requests with retry date")
        func tooManyRequestsWithRetryDate() throws {
            let response = Operations.PostOfrepV1EvaluateFlagsKey.Output.tooManyRequests(
                .init(headers: .init(retryAfter: Date(timeIntervalSince1970: 1_737_935_656)))
            )

            let resolution = OpenFeatureResolution(
                value: false,
                error: OpenFeatureResolutionError(
                    code: .general,
                    message: #"Too many requests. Retry after "2025-01-26T23:54:16Z"."#
                ),
                reason: .error
            )

            #expect(OpenFeatureResolution(response, defaultValue: false) == resolution)
        }

        @Test("Internal server error", arguments: ["Database connection failed.", nil])
        func internalServerError(message: String?) throws {
            let response = Operations.PostOfrepV1EvaluateFlagsKey.Output.internalServerError(
                .init(body: .json(.init(errorDetails: message)))
            )

            let resolution = OpenFeatureResolution(
                value: false,
                error: OpenFeatureResolutionError(code: .general, message: message),
                reason: .error
            )

            #expect(OpenFeatureResolution(response, defaultValue: false) == resolution)
        }

        @Test("Unknown status code")
        func internalServerError() throws {
            let response = Operations.PostOfrepV1EvaluateFlagsKey.Output.undocumented(statusCode: 418, .init())

            let resolution = OpenFeatureResolution(
                value: false,
                error: OpenFeatureResolutionError(
                    code: .general,
                    message: #"Received unexpected response status code "418"."#
                ),
                reason: .error
            )

            #expect(OpenFeatureResolution(response, defaultValue: false) == resolution)
        }

        @Test("Type mismatch", arguments: [true, false])
        func typeMismatch(defaultValue: Bool) {
            let response = Components.Schemas.ServerEvaluationSuccess(
                value1: .init(
                    value1: .init(
                        key: "flag",
                        reason: "TARGETING_MATCH",
                        variant: "b",
                        metadata: .init(additionalProperties: ["foo": .case2("bar")])
                    ),
                    value2: .StringFlag(.init(value: "💩"))
                ),
                value2: .init(cacheable: nil)
            )

            let resolution = OpenFeatureResolution(
                value: defaultValue,
                error: OpenFeatureResolutionError(
                    code: .typeMismatch,
                    message: #"Expected flag value of type "Bool" but received "String"."#
                ),
                reason: .error,
                variant: "b",
                flagMetadata: ["foo": .string("bar")]
            )

            #expect(OpenFeatureResolution(response, defaultValue: defaultValue) == resolution)
        }
    }

    @Test(
        "OFREP value type description",
        arguments: [
            "Bool": .BooleanFlag(.init(value: true)),
            "String": .StringFlag(.init(value: "string")),
            "Int": .IntegerFlag(.init(value: 42)),
            "Double": .FloatFlag(.init(value: 42.84)),
            "Object": .ObjectFlag(
                try! .init(value: .init(unvalidatedValue: ["foo": "bar"]))
            ),
        ] as [String: Components.Schemas.EvaluationSuccess.Value2Payload]
    )
    func valueTypeDescription(key: String, value: Components.Schemas.EvaluationSuccess.Value2Payload) {
        #expect(value.typeDescription == key)
    }

    @Suite("Flag metadata")
    struct FlagMetadataDecodingTests {
        @Test("Bool value", arguments: [true, false])
        func boolValue(value: Bool) {
            let payload = Components.Schemas.EvaluationSuccess.Value1Payload.MetadataPayload?(
                .init(additionalProperties: ["key": .case1(value)])
            )

            #expect(payload.toFlagMetadata() == ["key": .bool(value)])
        }

        @Test("String value")
        func stringValue() {
            let payload = Components.Schemas.EvaluationSuccess.Value1Payload.MetadataPayload?(
                .init(additionalProperties: ["key": .case2("value")])
            )

            #expect(payload.toFlagMetadata() == ["key": .string("value")])
        }

        @Test("Double value", arguments: [-Double.greatestFiniteMagnitude, 42, Double.greatestFiniteMagnitude])
        func doubleValue(value: Double) {
            let payload = Components.Schemas.EvaluationSuccess.Value1Payload.MetadataPayload?(
                .init(additionalProperties: ["key": .case3(value)])
            )

            #expect(payload.toFlagMetadata() == ["key": .double(value)])
        }

        @Test("Converts nil to empty metadata")
        func nilToEmpty() {
            let payload: Components.Schemas.EvaluationSuccess.Value1Payload.MetadataPayload? = nil

            #expect(payload.toFlagMetadata() == [:])
        }
    }
}
