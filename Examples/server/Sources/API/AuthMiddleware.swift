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

import HTTPTypes
import Hummingbird
import HummingbirdAuth

struct AuthMiddleware: AuthenticatorMiddleware {
    typealias Context = APIRequestContext

    func authenticate(request: Request, context: APIRequestContext) async throws -> User? {
        guard let userID = request.headers[.userID] else { return nil }
        return User(id: userID)
    }
}

extension HTTPField.Name {
    fileprivate static let userID = Self("X-User-Id")!
}
