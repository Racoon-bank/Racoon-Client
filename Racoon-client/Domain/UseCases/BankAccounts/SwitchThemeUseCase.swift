//
//  SwitchThemeUseCase.swift
//  Racoon-client
//
//  Created by dark type on 18.03.2026.
//


public protocol SwitchThemeUseCase: Sendable {
    func callAsFunction() async throws
}

public struct SwitchThemeUseCaseImpl: SwitchThemeUseCase {
    private let repo: InfoUserRepository
    private let events: DomainEventBus

    public init(repo: InfoUserRepository, events: DomainEventBus = NoopDomainEventBus()) {
        self.repo = repo
        self.events = events
    }

    public func callAsFunction() async throws {
        try await repo.switchTheme()
        await events.publish(.themeSwitched)
    }
}
