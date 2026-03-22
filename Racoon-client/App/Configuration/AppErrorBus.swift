//
//  AppErrorBus.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


public protocol AppErrorBus: Sendable {
    func stream() -> AsyncStream<AppErrorState>
    func post(_ error: AppErrorState)
}
