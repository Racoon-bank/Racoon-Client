//
//  NoopDomainEventBus.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


public struct NoopDomainEventBus: DomainEventBus {
    public let events: AsyncStream<DomainEvent>
    
    public init() {
        self.events = AsyncStream { continuation in
            continuation.finish()
        }
    }
    
    public func publish(_ event: DomainEvent) async {
        /* no-op */
    }
}
