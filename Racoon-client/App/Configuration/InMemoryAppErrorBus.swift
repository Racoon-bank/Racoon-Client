//
//  InMemoryAppErrorBus.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//

import Foundation

public actor InMemoryAppErrorBus: AppErrorBus {
    private var continuations: [UUID: AsyncStream<AppErrorState>.Continuation] = [:]

    public init() {}

    public func stream() -> AsyncStream<AppErrorState> {
        let id = UUID()

        return AsyncStream { continuation in
            continuations[id] = continuation

            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.removeContinuation(id)
                }
            }
        }
    }

    public func post(_ error: AppErrorState) {
        for continuation in continuations.values {
            continuation.yield(error)
        }
    }

    private func removeContinuation(_ id: UUID) {
        continuations.removeValue(forKey: id)
    }
}
