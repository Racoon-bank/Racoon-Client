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
    private let builder: RequestBuilder
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

        do {
            return try await perform(request, decodeAs: T.self)
        } catch let error as NetworkError {
            // DEBUG log for the first failure (useful to understand retry reasons)
            #if DEBUG
            print("⚠️ Request failed:", error)
            #endif

            if let retryRequest = await retryIfPossible(original: request, error: error) {
                #if DEBUG
                print("🔁 Retrying request:", retryRequest.httpMethod ?? "??", retryRequest.url?.absoluteString ?? "nil")
                #endif
                return try await perform(retryRequest, decodeAs: T.self)
            }

            throw error
        }
    }

    public func sendNoResponse(_ route: APIRouter) async throws {
        var request = try builder.build(route.endpoint)
        for i in interceptors {
            request = try await i.adapt(request)
        }

        do {
            _ = try await perform(request, decodeAs: EmptyResponse.self)
        } catch let error as NetworkError {
            #if DEBUG
            print("⚠️ Request failed (no response expected):", error)
            #endif

            if let retryRequest = await retryIfPossible(original: request, error: error) {
                #if DEBUG
                print("🔁 Retrying request:", retryRequest.httpMethod ?? "??", retryRequest.url?.absoluteString ?? "nil")
                #endif
                _ = try await perform(retryRequest, decodeAs: EmptyResponse.self)
                return
            }

            throw error
        }
    }

    // MARK: - Internals

    private func perform<T: Decodable>(_ request: URLRequest, decodeAs: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: request)

        // Log every response (success or failure)
        logger?.logResponse(request: request, response: response, data: data)

        try validate(response: response, data: data)

        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }

        guard !data.isEmpty else {
            throw NetworkError.emptyBody
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            // Log raw body so you can see which field breaks decoding
            #if DEBUG
            print("❌ Decoding \(T.self) failed:", error)
            if let s = String(data: data, encoding: .utf8) {
                print("❌ Body:", s)
            } else {
                print("❌ Body: <non-utf8 \(data.count) bytes>")
            }
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

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
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
