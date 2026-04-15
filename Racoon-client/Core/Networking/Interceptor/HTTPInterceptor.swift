//
//  HTTPInterceptor.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public protocol HTTPInterceptor: Sendable {
    func adapt(_ request: URLRequest) async throws -> URLRequest
    func retry(_ request: URLRequest, dueTo error: NetworkError, using client: HTTPClient) async -> URLRequest?
    
    func requestCompleted(_ request: URLRequest, response: HTTPURLResponse, data: Data, durationMs: Int) async
    func requestFailed(_ request: URLRequest, error: NetworkError, durationMs: Int) async
}

public extension HTTPInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest { request }
    func retry(_ request: URLRequest, dueTo error: NetworkError, using client: HTTPClient) async -> URLRequest? { nil }
    func requestCompleted(_ request: URLRequest, response: HTTPURLResponse, data: Data, durationMs: Int) async {}
    func requestFailed(_ request: URLRequest, error: NetworkError, durationMs: Int) async {}
}
