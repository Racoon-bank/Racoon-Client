//
//  NoopDomainEventBus.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


public struct NoopDomainEventBus: DomainEventBus {
    public init() {}
    public func publish(_ event: DomainEvent) async { /* no-op */ }
}