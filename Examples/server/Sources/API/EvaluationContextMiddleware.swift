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

import Hummingbird
import OpenFeature

struct EvaluationContextMiddleware: MiddlewareProtocol {
    func handle(
        _ request: Request,
        context: APIRequestContext,
        next: (Request, APIRequestContext) async throws -> Response
    ) async throws -> Response {
        var evaluationContext = OpenFeatureEvaluationContext.current ?? OpenFeatureEvaluationContext()
        evaluationContext.targetingKey = context.identity?.id
        return try await OpenFeatureEvaluationContext.$current.withValue(evaluationContext) {
            try await next(request, context)
        }
    }
}
