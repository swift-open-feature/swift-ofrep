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

import OpenFeature

extension OpenFeatureResolution<Bool> {
    package init(_ response: Operations.EvaluateFlag.Output, defaultValue: Bool) {
        switch response {
        case .ok(let ok):
            switch ok.body {
            case .json(let responsePayload):
                self = OpenFeatureResolution(responsePayload, defaultValue: defaultValue)
            }
        case .badRequest(let badRequest):
            switch badRequest.body {
            case .json(let responsePayload):
                self = OpenFeatureResolution(
                    value: defaultValue,
                    error: .init(
                        code: .init(rawValue: responsePayload.errorCode.rawValue),
                        message: responsePayload.errorDetails
                    ),
                    reason: .error
                )
            }
        case .notFound(let notFound):
            switch notFound.body {
            case .json(let responsePayload):
                self = OpenFeatureResolution(
                    value: defaultValue,
                    error: .init(
                        code: .init(rawValue: responsePayload.errorCode.rawValue),
                        message: responsePayload.errorDetails
                    ),
                    reason: .error
                )
            }
        case .unauthorized:
            self = OpenFeatureResolution(
                value: defaultValue,
                error: OpenFeatureResolutionError(code: .general, message: "Unauthorized."),
                reason: .error
            )
        case .forbidden:
            self = OpenFeatureResolution(
                value: defaultValue,
                error: OpenFeatureResolutionError(code: .general, message: "Forbidden."),
                reason: .error
            )
        case .tooManyRequests(let responsePayload):
            let message: String
            if let retryAfter = responsePayload.headers.retryAfter {
                let dateString = retryAfter.ISO8601Format(.iso8601WithTimeZone())
                message = #"Too many requests. Retry after "\#(dateString)"."#
            } else {
                message = "Too many requests."
            }
            self = OpenFeatureResolution(
                value: defaultValue,
                error: OpenFeatureResolutionError(code: .general, message: message),
                reason: .error
            )
        case .internalServerError(let internalServerError):
            switch internalServerError.body {
            case .json(let responsePayload):
                self = OpenFeatureResolution(
                    value: defaultValue,
                    error: OpenFeatureResolutionError(code: .general, message: responsePayload.errorDetails),
                    reason: .error
                )
            }
        case .undocumented(let statusCode, _):
            self = OpenFeatureResolution(
                value: defaultValue,
                error: OpenFeatureResolutionError(
                    code: .general,
                    message: #"Received unexpected response status code "\#(statusCode)"."#
                ),
                reason: .error
            )
        }
    }
}

extension OpenFeatureResolution<Bool> {
    package init(
        _ response: Components.Schemas.ServerEvaluationSuccess,
        defaultValue: Bool
    ) {
        let variant = response.value1.value1.variant
        let flagMetadata = response.value1.value1.metadata.toFlagMetadata()

        switch response.value1.value2 {
        case .BooleanFlag(let boolContainer):
            self.init(
                value: boolContainer.value,
                error: nil,
                reason: response.value1.value1.reason.map(OpenFeatureResolutionReason.init),
                variant: variant,
                flagMetadata: flagMetadata
            )
        default:
            self.init(
                value: defaultValue,
                error: OpenFeatureResolutionError(
                    code: .typeMismatch,
                    message: response.value1.value2.typeMismatchErrorMessage(expectedType: "\(Value.self)")
                ),
                reason: .error,
                variant: variant,
                flagMetadata: flagMetadata
            )
        }
    }
}

extension Components.Schemas.EvaluationSuccess.Value1Payload.MetadataPayload? {
    package func toFlagMetadata() -> [String: OpenFeatureFlagMetadataValue] {
        self?.value1.additionalProperties.mapValues(OpenFeatureFlagMetadataValue.init) ?? [:]
    }
}

extension OpenFeatureFlagMetadataValue {
    package init(
        _ payload: Components.Schemas.Metadata.AdditionalPropertiesPayload
    ) {
        self =
            switch payload {
            case .case1(let value): .bool(value)
            case .case2(let value): .string(value)
            case .case3(let value): .double(value)
            }
    }
}

extension Components.Schemas.EvaluationSuccess.Value2Payload {
    package var typeDescription: String {
        switch self {
        case .BooleanFlag: "Bool"
        case .StringFlag: "String"
        case .IntegerFlag: "Int"
        case .FloatFlag: "Double"
        case .ObjectFlag: "Object"
        }
    }

    func typeMismatchErrorMessage(expectedType: String) -> String {
        #"Expected flag value of type "\#(expectedType)" but received "\#(typeDescription)"."#
    }
}
