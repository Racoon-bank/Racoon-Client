//
//  DomainEventBus.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public protocol DomainEventBus: Sendable {
    func publish(_ event: DomainEvent) async
    var events: AsyncStream<DomainEvent> { get }
}

