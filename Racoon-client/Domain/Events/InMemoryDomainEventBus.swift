//
//  InMemoryDomainEventBus.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public actor InMemoryDomainEventBus: DomainEventBus {
    private var continuations: [UUID: AsyncStream<DomainEvent>.Continuation] = [:]

    public init() {}

    public func publish(_ event: DomainEvent) {
        for continuation in continuations.values {
            continuation.yield(event)
        }
    }

    public nonisolated var events: AsyncStream<DomainEvent> {
        AsyncStream { continuation in
            let id = UUID()
            
            Task { await self.addContinuation(id, continuation) }
            
            continuation.onTermination = { _ in
                Task { await self.removeContinuation(id) }
            }
        }
    }

    private func addContinuation(_ id: UUID, _ continuation: AsyncStream<DomainEvent>.Continuation) {
        continuations[id] = continuation
    }

    private func removeContinuation(_ id: UUID) {
        continuations.removeValue(forKey: id)
    }
}
