//
//  HTTPClient.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


import Foundation

public final class HTTPClient: @unchecked Sendable {
    private let session: URLSession
    private let decoder: JSONDecoder
    public let builder: RequestBuilder // Made public so monitoring batcher can reuse it
    private let interceptors: [HTTPInterceptor]
    
    private var logger: NetworkLoggerInterceptor? {
        interceptors.compactMap { $0 as? NetworkLoggerInterceptor }.first
    }
    
    public init(
        session: URLSession = .shared,
        builder: RequestBuilder,
        decoder: JSONDecoder,
        interceptors: [HTTPInterceptor] = []
    ) {
        self.session = session
        self.builder = builder
        self.decoder = decoder
        self.interceptors = interceptors
    }
    
    public func send<T: Decodable>(_ route: APIRouter, as type: T.Type) async throws -> T {
        var request = try builder.build(route.endpoint)
        for i in interceptors {
            request = try await i.adapt(request)
        }
        
        return try await executeWithRetries(request: request, decodeAs: T.self)
    }
    
    public func sendNoResponse(_ route: APIRouter) async throws {
        var request = try builder.build(route.endpoint)
        for i in interceptors {
            request = try await i.adapt(request)
        }
        
        _ = try await executeWithRetries(request: request, decodeAs: EmptyResponse.self)
    }
    
        // MARK: - Internals
    
    private func executeWithRetries<T: Decodable>(request: URLRequest, decodeAs: T.Type) async throws -> T {
        var currentRequest = request
        
        while true {
            let startTime = Date()
            do {
                let result = try await perform(currentRequest, decodeAs: T.self)
                let durationMs = Int(Date().timeIntervalSince(startTime) * 1000)
                
                return result
            } catch let error as NetworkError {
                let durationMs = Int(Date().timeIntervalSince(startTime) * 1000)
                
                for i in interceptors {
                    await i.requestFailed(currentRequest, error: error, durationMs: durationMs)
                }
                
#if DEBUG
                print("⚠️ Request failed:", error)
#endif
                
                if let retryRequest = await retryIfPossible(original: currentRequest, error: error) {
#if DEBUG
                    print("🔁 Retrying request:", retryRequest.httpMethod ?? "??", retryRequest.url?.absoluteString ?? "nil")
#endif
                    currentRequest = retryRequest
                    continue
                }
                
                throw error
            }
        }
    }
    
    private func perform<T: Decodable>(_ request: URLRequest, decodeAs: T.Type) async throws -> T {
        let data: Data
        let response: URLResponse
        let startTime = Date()
        
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            throw NetworkError.transport(urlError)
        } catch {
            throw NetworkError.unknown
        }
        
        logger?.logResponse(request: request, response: response, data: data)
        
        let durationMs = Int(Date().timeIntervalSince(startTime) * 1000)
        try await validateAndNotify(request: request, response: response, data: data, durationMs: durationMs)
        
        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
#if DEBUG
            print("❌ Decoding \(T.self) failed:", error)
#endif
            throw NetworkError.decoding(error)
        }
    }
    
    private func retryIfPossible(original: URLRequest, error: NetworkError) async -> URLRequest? {
        for i in interceptors {
            if let newRequest = await i.retry(original, dueTo: error, using: self) {
                return newRequest
            }
        }
        return nil
    }
    
    private func validateAndNotify(request: URLRequest, response: URLResponse, data: Data, durationMs: Int) async throws {
        guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        
        for i in interceptors {
            await i.requestCompleted(request, response: http, data: data, durationMs: durationMs)
        }
        
        switch http.statusCode {
        case 200..<300:
            return
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.httpStatus(code: http.statusCode, body: data)
        }
    }
}

private struct EmptyResponse: Decodable { }
