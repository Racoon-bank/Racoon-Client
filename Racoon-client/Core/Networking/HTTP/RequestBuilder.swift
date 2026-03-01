//
//  RequestBuilder.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

import Foundation

public protocol RequestBuilder: Sendable {
    func build(_ endpoint: Endpoint) throws -> URLRequest
}

public struct DefaultRequestBuilder: RequestBuilder {
    private let env: NetworkEnvironment
    private let encoder: JSONEncoder

    public init(env: NetworkEnvironment, encoder: JSONEncoder) {
        self.env = env
        self.encoder = encoder
    }

    public func build(_ endpoint: Endpoint) throws -> URLRequest {
        let baseURL = env.baseURL(for: endpoint.service)

        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        let basePath = components.path
        components.path = joinPaths(basePath, endpoint.path)
        components.queryItems = endpoint.query.isEmpty ? nil : endpoint.query

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        request.setValue("application/json", forHTTPHeaderField: "Accept")

        for (k, v) in endpoint.headers {
            request.setValue(v, forHTTPHeaderField: k)
        }

        if let data = try endpoint.body.encode(using: encoder) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        }

        return request
    }

    private func joinPaths(_ a: String, _ b: String) -> String {
        let left = a.hasSuffix("/") ? String(a.dropLast()) : a
        let right = b.hasPrefix("/") ? String(b.dropFirst()) : b
        if left.isEmpty { return "/" + right }
        return left + "/" + right
    }
}
