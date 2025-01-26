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
import OpenAPIRuntime
import OpenFeature

extension Components.Schemas.Context {
    package init(_ context: OpenFeatureEvaluationContext) throws {
        let additionalProperties = try OpenAPIObjectContainer(context.fields)
        self.init(targetingKey: context.targetingKey, additionalProperties: additionalProperties)
    }
}

extension OpenAPIObjectContainer {
    fileprivate init(_ fields: [String: OpenFeatureFieldValue]) throws {
        var values = [String: any Sendable]()

        for (key, value) in fields {
            switch value {
            case .bool(let value):
                values[key] = value
            case .string(let value):
                values[key] = value
            case .int(let value):
                values[key] = value
            case .double(let value):
                values[key] = value
            case .date(let value):
                values[key] = value.timeIntervalSince1970
            case .object(let value):
                let data = try Self.jsonEncoder.encode(value)
                let container = try Self.jsonDecoder.decode(OpenAPIObjectContainer.self, from: data)
                values[key] = container.value
            }
        }

        try self.init(unvalidatedValue: values)
    }

    private static let jsonEncoder = JSONEncoder()
    private static let jsonDecoder = JSONDecoder()
}
