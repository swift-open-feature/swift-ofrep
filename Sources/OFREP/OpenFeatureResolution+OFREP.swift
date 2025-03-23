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
        self.init(response, defaultValue: defaultValue) { response in
            guard case .BooleanFlag(let flag) = response else { return nil }
            return flag.value
        }
    }
}

extension OpenFeatureResolution<String> {
    package init(_ response: Operations.EvaluateFlag.Output, defaultValue: String) {
        self.init(response, defaultValue: defaultValue) { response in
            guard case .StringFlag(let flag) = response else { return nil }
            return flag.value
        }
    }
}

extension OpenFeatureResolution<Int> {
    package init(_ response: Operations.EvaluateFlag.Output, defaultValue: Int) {
        self.init(response, defaultValue: defaultValue) { response in
            guard case .IntegerFlag(let flag) = response else { return nil }
            return flag.value
        }
    }
}

extension OpenFeatureResolution<Double> {
    package init(_ response: Operations.EvaluateFlag.Output, defaultValue: Double) {
        self.init(response, defaultValue: defaultValue) { response in
            guard case .FloatFlag(let flag) = response else { return nil }
            return flag.value
        }
    }
}

extension OpenFeatureResolution {
    package init(
        _ response: Operations.EvaluateFlag.Output,
        defaultValue: Value,
        transformSuccessfulResponse: (Components.Schemas.EvaluationSuccess.Value2Payload) -> Value?
    ) {
        switch response {
        case .ok(let ok):
            switch ok.body {
            case .json(let jsonPayload):
                let variant = jsonPayload.value1.value1.variant
                let flagMetadata = jsonPayload.value1.value1.metadata.toFlagMetadata()

                if let value = transformSuccessfulResponse(jsonPayload.value1.value2) {
                    self = OpenFeatureResolution(
                        value: value,
                        error: nil,
                        reason: jsonPayload.value1.value1.reason.map(OpenFeatureResolutionReason.init),
                        variant: variant,
                        flagMetadata: flagMetadata
                    )
                } else {
                    self = OpenFeatureResolution(
                        value: defaultValue,
                        error: OpenFeatureResolutionError(
                            code: .typeMismatch,
                            message: jsonPayload.value1.value2.typeMismatchErrorMessage(expectedType: "\(Value.self)")
                        ),
                        reason: .error,
                        variant: variant,
                        flagMetadata: flagMetadata
                    )
                }
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
