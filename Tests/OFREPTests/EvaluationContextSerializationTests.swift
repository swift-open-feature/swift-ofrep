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

@Suite("Evaluation Context Serialization")
struct EvaluationContextSerializationTests {
    @Test("without targeting key")
    func withoutTargetingKey() throws {
        let context = OpenFeatureEvaluationContext(targetingKey: nil, fields: [:])

        let ofrepContext = Components.Schemas.Context(
            targetingKey: nil,
            additionalProperties: OpenAPIObjectContainer()
        )

        try #expect(Components.Schemas.Context(context) == ofrepContext)
    }

    @Test("with targeting key")
    func withTargetingKey() throws {
        let targetingKey = UUID().uuidString
        let context = OpenFeatureEvaluationContext(targetingKey: targetingKey, fields: [:])

        let ofrepContext = Components.Schemas.Context(
            targetingKey: targetingKey,
            additionalProperties: OpenAPIObjectContainer()
        )

        try #expect(Components.Schemas.Context(context) == ofrepContext)
    }

    @Test("Bool field", arguments: [true, false])
    func boolField(value: Bool) throws {
        let context = OpenFeatureEvaluationContext(fields: ["correct": .bool(value)])

        let ofrepContext = Components.Schemas.Context(
            additionalProperties: try OpenAPIObjectContainer(unvalidatedValue: ["correct": value])
        )

        try #expect(Components.Schemas.Context(context) == ofrepContext)
    }

    @Test("String field")
    func stringField() throws {
        let context = OpenFeatureEvaluationContext(fields: ["language": "swift"])

        let ofrepContext = Components.Schemas.Context(
            additionalProperties: try OpenAPIObjectContainer(unvalidatedValue: ["language": "swift"])
        )

        try #expect(Components.Schemas.Context(context) == ofrepContext)
    }

    @Test("Int field", arguments: [Int.min, 42, Int.max])
    func intField(value: Int) throws {
        let context = OpenFeatureEvaluationContext(fields: ["count": .int(value)])

        let ofrepContext = Components.Schemas.Context(
            additionalProperties: try OpenAPIObjectContainer(unvalidatedValue: ["count": value])
        )

        try #expect(Components.Schemas.Context(context) == ofrepContext)
    }

    @Test("Double field", arguments: [-Double.greatestFiniteMagnitude, 42, Double.greatestFiniteMagnitude])
    func doubleField(value: Double) throws {
        let context = OpenFeatureEvaluationContext(fields: ["count": .double(value)])

        let ofrepContext = Components.Schemas.Context(
            additionalProperties: try OpenAPIObjectContainer(unvalidatedValue: ["count": value])
        )

        try #expect(Components.Schemas.Context(context) == ofrepContext)
    }

    @Test("Date field")
    func doubleField() throws {
        let context = OpenFeatureEvaluationContext(fields: ["date": .date(Date(timeIntervalSince1970: 42))])

        let ofrepContext = Components.Schemas.Context(
            additionalProperties: try OpenAPIObjectContainer(unvalidatedValue: ["date": 42.0])
        )

        try #expect(Components.Schemas.Context(context) == ofrepContext)
    }

    @Test("Object field")
    func objectField() throws {
        struct Object: Codable, Sendable {
            let foo: String
            let nested: Nested

            struct Nested: Codable, Sendable {
                let foo: String
                let values: [Bool]
            }
        }

        let context = OpenFeatureEvaluationContext(
            fields: ["object": .object(Object(foo: "bar", nested: .init(foo: "bar", values: [true, false])))]
        )

        let ofrepContext = Components.Schemas.Context(
            additionalProperties: try OpenAPIObjectContainer(
                unvalidatedValue: [
                    "object": [
                        "foo": "bar",
                        "nested": [
                            "foo": "bar",
                            "values": [true, false],
                        ] as [String: any Sendable],
                    ] as [String: any Sendable]
                ]
            )
        )

        try #expect(Components.Schemas.Context(context) == ofrepContext)
    }
}
