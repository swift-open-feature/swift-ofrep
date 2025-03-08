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

struct FeedController {
    private let featureFlags: OpenFeatureClient

    init() {
        featureFlags = OpenFeatureSystem.client()
    }

    var routes: RouteCollection<APIRequestContext> {
        let routes = RouteCollection(context: APIRequestContext.self)
        routes.get(use: list)
        return routes
    }

    private func list(request: Request, context: APIRequestContext) async throws -> Feed {
        let useNewFeedAlgorithm = await featureFlags.value(for: "experimental-feed-algorithm", defaultingTo: false)

        if useNewFeedAlgorithm {
            // the new algorithm is faster but unfortunately still contains some bugs
            if UInt.random(in: 0..<100) == 42 {
                throw HTTPError(.internalServerError)
            }
            try await Task.sleep(for: .seconds(1))
            return Feed.stub
        } else {
            try await Task.sleep(for: .seconds(2))
            return Feed.stub
        }
    }
}

struct Feed: ResponseCodable {
    let posts: [Post]

    struct Post: ResponseCodable {
        let id: String
    }

    static let stub = Feed(posts: [
        Post(id: "1"),
        Post(id: "2"),
        Post(id: "3"),
    ])
}
