//
//  CircuitBreakerInterceptor.swift
//  Racoon-client
//
//  Created by dark type on 15.04.2026.
//

import Foundation

public final class CircuitBreakerInterceptor: HTTPInterceptor {
    private let appErrorBus: AppErrorBus
    private let state = CircuitBreakerState()
    
    public init(appErrorBus: AppErrorBus) {
        self.appErrorBus = appErrorBus
    }
    
    private func trackingId(for request: URLRequest) -> String {
        if let idempotencyKey = request.value(forHTTPHeaderField: "Idempotency-Key") {
            return idempotencyKey
        }
        return "\(request.httpMethod ?? "GET")_\(request.url?.absoluteString ?? "unknown")"
    }
    
    public func retry(_ request: URLRequest, dueTo error: NetworkError, using client: HTTPClient) async -> URLRequest? {
        guard case .httpStatus(let code, _) = error, code >= 500, code < 600 else {
            return nil
        }
        
        let id = trackingId(for: request)
        let canRetry = await state.incrementAndCheck(id: id)
        
        if canRetry {
            print("🔄 CircuitBreaker: Retrying 500 error for \(id)")
            return request
        } else {
            print("🚨 CircuitBreaker: Max retries (3) reached. Tripping breaker and notifying AppErrorBus.")
            appErrorBus.post(
                AppErrorState(
                    title: "Server Error",
                    message: "The server is currently experiencing issues. Please try again later.",
                    kind: .fallback
                )
            )
            return nil
        }
    }
    
    public func requestCompleted(_ request: URLRequest, response: HTTPURLResponse, data: Data, durationMs: Int) async {
        let id = trackingId(for: request)
        await state.clear(id: id)
    }
}
