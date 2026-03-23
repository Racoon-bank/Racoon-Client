//
//  AppErrorMapper.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//

import Foundation

public struct AppErrorMapper: Sendable {
    public init() {}

    public func mapNetworkToGlobal(_ error: NetworkError) -> AppErrorState? {
        switch error {
        case .invalidResponse, .emptyBody, .decoding:
            return AppErrorState(
                title: "Service error",
                message: "The server returned invalid data.",
                kind: .fallback,
                canRetry: true
            )

        case .httpStatus(let code, _):
            if code == 403 {
                return AppErrorState(
                    title: "Access error",
                    message: "The server rejected the request unexpectedly.",
                    kind: .fallback,
                    canRetry: true
                )
            }

            if (500...599).contains(code) {
                return AppErrorState(
                    title: "Server unavailable",
                    message: "The service is temporarily unavailable.",
                    kind: .fallback,
                    canRetry: true
                )
            }

            return nil

        case .transport(let urlError):
            switch urlError.code {
            case .cannotConnectToHost, .cannotFindHost, .badServerResponse:
                return AppErrorState(
                    title: "Connection problem",
                    message: "Cannot reach the server right now.",
                    kind: .fallback,
                    canRetry: true
                )
            default:
                return nil
            }

        default:
            return nil
        }
    }
}
