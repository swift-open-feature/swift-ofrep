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
            let response = Operations.EvaluateFlag.Output.ok(
                .init(
                    body: .json(
                        Components.Schemas.ServerEvaluationSuccess(
                            value1: .init(
                                value1: .init(
                                    key: "flag",
                                    reason: "TARGETING_MATCH",
                                    variant: "b",
                                    metadata: .init(
                                        value1: .init(additionalProperties: ["foo": .case2("bar")]),
                                        value2: "",
                                        value3: ""
                                    )
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

        @Test("Type mismatch")
        func typeMismatch() {
            let response = Components.Schemas.ServerEvaluationSuccess(
                value1: .init(
                    value1: .init(
                        key: "flag",
                        reason: "TARGETING_MATCH",
                        variant: "b",
                        metadata: .init(
                            value1: .init(additionalProperties: ["foo": .case2("bar")]),
                            value2: "",
                            value3: ""
                        )
                    ),
                    value2: .StringFlag(.init(value: "💩"))
                ),
                value2: .init(cacheable: nil)
            )

            let expectedResolution = OpenFeatureResolution(
                value: true,
                error: OpenFeatureResolutionError(
                    code: .typeMismatch,
                    message: #"Expected flag value of type "Bool" but received "String"."#
                ),
                reason: .error,
                variant: "b",
                flagMetadata: ["foo": .string("bar")]
            )

            let resolution = OpenFeatureResolution(
                Operations.EvaluateFlag.Output.ok(.init(body: .json(response))),
                defaultValue: true
            )

            #expect(resolution == expectedResolution)
        }
    }

    @Suite("String")
    struct StringResolutionDecodingTests {
        @Test("Success", arguments: ["Hello", ""])
        func success(value: String) {
            let response = Operations.EvaluateFlag.Output.ok(
                .init(
                    body: .json(
                        Components.Schemas.ServerEvaluationSuccess(
                            value1: .init(
                                value1: .init(
                                    key: "flag",
                                    reason: "TARGETING_MATCH",
                                    variant: "b",
                                    metadata: .init(
                                        value1: .init(additionalProperties: ["foo": .case2("bar")]),
                                        value2: "",
                                        value3: ""
                                    )
                                ),
                                value2: .StringFlag(.init(value: value))
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

            #expect(OpenFeatureResolution(response, defaultValue: "default") == resolution)
        }

        @Test("Type mismatch")
        func typeMismatch() {
            let response = Components.Schemas.ServerEvaluationSuccess(
                value1: .init(
                    value1: .init(
                        key: "flag",
                        reason: "TARGETING_MATCH",
                        variant: "b",
                        metadata: .init(
                            value1: .init(additionalProperties: ["foo": .case2("bar")]),
                            value2: "",
                            value3: ""
                        )
                    ),
                    value2: .BooleanFlag(.init(value: true))
                ),
                value2: .init(cacheable: nil)
            )

            let expectedResolution = OpenFeatureResolution(
                value: "Hello",
                error: OpenFeatureResolutionError(
                    code: .typeMismatch,
                    message: #"Expected flag value of type "String" but received "Bool"."#
                ),
                reason: .error,
                variant: "b",
                flagMetadata: ["foo": .string("bar")]
            )

            let resolution = OpenFeatureResolution(
                Operations.EvaluateFlag.Output.ok(.init(body: .json(response))),
                defaultValue: "Hello"
            )

            #expect(resolution == expectedResolution)
        }
    }

    @Suite("Int")
    struct IntResolutionDecodingTests {
        @Test("Success", arguments: [Int.min, 0, Int.max])
        func success(value: Int) {
            let response = Operations.EvaluateFlag.Output.ok(
                .init(
                    body: .json(
                        Components.Schemas.ServerEvaluationSuccess(
                            value1: .init(
                                value1: .init(
                                    key: "flag",
                                    reason: "TARGETING_MATCH",
                                    variant: "b",
                                    metadata: .init(
                                        value1: .init(additionalProperties: ["foo": .case2("bar")]),
                                        value2: "",
                                        value3: ""
                                    )
                                ),
                                value2: .IntegerFlag(.init(value: value))
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

            #expect(OpenFeatureResolution(response, defaultValue: 42) == resolution)
        }

        @Test("Type mismatch")
        func typeMismatch() {
            let response = Components.Schemas.ServerEvaluationSuccess(
                value1: .init(
                    value1: .init(
                        key: "flag",
                        reason: "TARGETING_MATCH",
                        variant: "b",
                        metadata: .init(
                            value1: .init(additionalProperties: ["foo": .case2("bar")]),
                            value2: "",
                            value3: ""
                        )
                    ),
                    value2: .StringFlag(.init(value: "💩"))
                ),
                value2: .init(cacheable: nil)
            )

            let expectedResolution = OpenFeatureResolution(
                value: 42,
                error: OpenFeatureResolutionError(
                    code: .typeMismatch,
                    message: #"Expected flag value of type "Int" but received "String"."#
                ),
                reason: .error,
                variant: "b",
                flagMetadata: ["foo": .string("bar")]
            )

            let resolution = OpenFeatureResolution(
                Operations.EvaluateFlag.Output.ok(.init(body: .json(response))),
                defaultValue: 42
            )

            #expect(resolution == expectedResolution)
        }
    }

    @Suite("Double")
    struct DoubleResolutionDecodingTests {
        @Test("Success", arguments: [-Double.greatestFiniteMagnitude, 42.123, Double.greatestFiniteMagnitude])
        func success(value: Double) {
            let response = Operations.EvaluateFlag.Output.ok(
                .init(
                    body: .json(
                        Components.Schemas.ServerEvaluationSuccess(
                            value1: .init(
                                value1: .init(
                                    key: "flag",
                                    reason: "TARGETING_MATCH",
                                    variant: "b",
                                    metadata: .init(
                                        value1: .init(additionalProperties: ["foo": .case2("bar")]),
                                        value2: "",
                                        value3: ""
                                    )
                                ),
                                value2: .FloatFlag(.init(value: value))
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

            #expect(OpenFeatureResolution(response, defaultValue: 0.0) == resolution)
        }

        @Test("Type mismatch")
        func typeMismatch() {
            let response = Components.Schemas.ServerEvaluationSuccess(
                value1: .init(
                    value1: .init(
                        key: "flag",
                        reason: "TARGETING_MATCH",
                        variant: "b",
                        metadata: .init(
                            value1: .init(additionalProperties: ["foo": .case2("bar")]),
                            value2: "",
                            value3: ""
                        )
                    ),
                    value2: .StringFlag(.init(value: "💩"))
                ),
                value2: .init(cacheable: nil)
            )

            let expectedResolution = OpenFeatureResolution(
                value: 42.0,
                error: OpenFeatureResolutionError(
                    code: .typeMismatch,
                    message: #"Expected flag value of type "Double" but received "String"."#
                ),
                reason: .error,
                variant: "b",
                flagMetadata: ["foo": .string("bar")]
            )

            let resolution = OpenFeatureResolution(
                Operations.EvaluateFlag.Output.ok(.init(body: .json(response))),
                defaultValue: 42.0
            )

            #expect(resolution == expectedResolution)
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

    @Test("Bad request", arguments: ["Targeting key is required.", nil])
    func badRequest(message: String?) {
        let response = Operations.EvaluateFlag.Output.badRequest(
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
        let response = Operations.EvaluateFlag.Output.notFound(
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
        let response = Operations.EvaluateFlag.Output.unauthorized(.init())

        let resolution = OpenFeatureResolution(
            value: false,
            error: OpenFeatureResolutionError(code: .general, message: "Unauthorized."),
            reason: .error
        )

        #expect(OpenFeatureResolution(response, defaultValue: false) == resolution)
    }

    @Test("Forbidden")
    func forbidden() throws {
        let response = Operations.EvaluateFlag.Output.forbidden(.init())

        let resolution = OpenFeatureResolution(
            value: false,
            error: OpenFeatureResolutionError(code: .general, message: "Forbidden."),
            reason: .error
        )

        #expect(OpenFeatureResolution(response, defaultValue: false) == resolution)
    }

    @Test("Too many requests without retry date")
    func tooManyRequests() throws {
        let response = Operations.EvaluateFlag.Output.tooManyRequests(.init())

        let resolution = OpenFeatureResolution(
            value: false,
            error: OpenFeatureResolutionError(code: .general, message: "Too many requests."),
            reason: .error
        )

        #expect(OpenFeatureResolution(response, defaultValue: false) == resolution)
    }

    @Test("Too many requests with retry date")
    func tooManyRequestsWithRetryDate() throws {
        let response = Operations.EvaluateFlag.Output.tooManyRequests(
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
        let response = Operations.EvaluateFlag.Output.internalServerError(
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
        let response = Operations.EvaluateFlag.Output.undocumented(statusCode: 418, .init())

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

    @Suite("Flag metadata")
    struct FlagMetadataDecodingTests {
        @Test("Bool value", arguments: [true, false])
        func boolValue(value: Bool) {
            let payload = Components.Schemas.EvaluationSuccess.Value1Payload.MetadataPayload?(
                .init(
                    value1: .init(additionalProperties: ["key": .case1(value)]),
                    value2: "",
                    value3: ""
                )
            )

            #expect(payload.toFlagMetadata() == ["key": .bool(value)])
        }

        @Test("String value")
        func stringValue() {
            let payload = Components.Schemas.EvaluationSuccess.Value1Payload.MetadataPayload?(
                .init(
                    value1: .init(additionalProperties: ["key": .case2("value")]),
                    value2: "",
                    value3: ""
                )
            )

            #expect(payload.toFlagMetadata() == ["key": .string("value")])
        }

        @Test("Double value", arguments: [-Double.greatestFiniteMagnitude, 42, Double.greatestFiniteMagnitude])
        func doubleValue(value: Double) {
            let payload = Components.Schemas.EvaluationSuccess.Value1Payload.MetadataPayload?(
                .init(
                    value1: .init(additionalProperties: ["key": .case3(value)]),
                    value2: "",
                    value3: ""
                )
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
