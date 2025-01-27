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

import ServiceLifecycle

private struct ShutdownTriggerService: Service, CustomStringConvertible {
    let description = "ShutdownTrigger"

    func run() async throws {}
}

extension ServiceGroupConfiguration.ServiceConfiguration {
    /// A no-op service which is used to shut down the service group upon successful termination.
    static let shutdownTrigger = Self(
        service: ShutdownTriggerService(),
        successTerminationBehavior: .gracefullyShutdownGroup
    )
}
