//
//  AppErrorMapper.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


public struct AppErrorMapper: Sendable {
    public init() {}

    public func mapToGlobal(_ error: DomainError) -> AppErrorState? {
        switch error {
        case .unauthorized:
            return AppErrorState(
                title: "Session expired",
                message: "Please sign in again.",
                kind: .forceLogout
            )

        case .serverUnavailable:
            return AppErrorState(
                title: "Service unavailable",
                message: "The application is temporarily unavailable.",
                kind: .fallback,
                canRetry: true
            )

        case .noInternet:
            return AppErrorState(
                title: "No internet connection",
                message: "Check your connection and try again.",
                kind: .banner
            )

        case .timeout, .forbidden, .unknown:
            return nil
        }
    }
}