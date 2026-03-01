//
//  NetworkLoggerInterceptor.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import Foundation

public final class NetworkLoggerInterceptor: HTTPInterceptor, @unchecked Sendable {
    private let enabled: Bool
    private let bodyLimit: Int

    public init(enabled: Bool, bodyLimit: Int = 8_000) {
        self.enabled = enabled
        self.bodyLimit = bodyLimit
    }

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        guard enabled else { return request }

        print("➡️ \(request.httpMethod ?? "??") \(request.url?.absoluteString ?? "nil")")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("   headers:", headers)
        }

        if let data = request.httpBody, !data.isEmpty {
            print("   body:", pretty(data: data))
        }

        return request
    }

    public func retry(_ request: URLRequest, dueTo error: NetworkError, using client: HTTPClient) async -> URLRequest? {
        // Logger never retries.
        return nil
    }

    public func logResponse(request: URLRequest, response: URLResponse, data: Data) {
        guard enabled else { return }
        guard let http = response as? HTTPURLResponse else {
            print("⬅️ response: (non-http)")
            return
        }

        print("⬅️ \(http.statusCode) \(request.httpMethod ?? "??") \(request.url?.absoluteString ?? "nil")")

        if !data.isEmpty {
            let clipped = data.prefix(bodyLimit)
            print("   body:", pretty(data: Data(clipped)))
            if data.count > bodyLimit {
                print("   body: (truncated \(data.count - bodyLimit) bytes)")
            }
        } else {
            print("   body: <empty>")
        }
    }

    private func pretty(data: Data) -> String {
        if let json = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
           let s = String(data: pretty, encoding: .utf8) {
            return s
        }
        return String(data: data, encoding: .utf8) ?? "<non-utf8 \(data.count) bytes>"
    }
}
