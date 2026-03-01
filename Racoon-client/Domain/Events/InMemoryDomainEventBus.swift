//
//  InMemoryDomainEventBus.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public actor InMemoryDomainEventBus: DomainEventBus {
    private var observers: [(DomainEvent) -> Void] = []

    public init() {}

    public func addObserver(_ observer: @escaping (DomainEvent) -> Void) {
        observers.append(observer)
    }

    public func publish(_ event: DomainEvent) async {
        observers.forEach { $0(event) }
    }
}