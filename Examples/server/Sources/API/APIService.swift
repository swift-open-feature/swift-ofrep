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
import ServiceLifecycle

public struct APIService: Service {
    private let app: Application<RouterResponder<APIRequestContext>>
    private let client: OpenFeatureClient

    public init(router: Router<APIRequestContext>) {
        client = OpenFeatureSystem.client()

        router
            .addMiddleware {
                AuthMiddleware()
                EvaluationContextMiddleware()
            }
            .addRoutes(FeedController().routes)

        app = Application(router: router)
    }

    public func run() async throws {
        try await app.run()
    }
}
