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
import HummingbirdAuth

public struct APIRequestContext: AuthRequestContext, Sendable {
    public var coreContext: CoreRequestContextStorage
    public var identity: User?

    public init(source: ApplicationRequestContextSource) {
        coreContext = .init(source: source)
    }
}
