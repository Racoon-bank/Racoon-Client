//
//  NetworkingAssembly.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//

import Foundation

public struct NetworkingAssembly: Sendable {
    public let env: NetworkEnvironment

    public init(env: NetworkEnvironment) {
        self.env = env
    }

    public func makeJSONDecoder() -> JSONDecoder {
        let d = JSONDecoder()

        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let s = try container.decode(String.self)

            if let date = DateParsers.dateOnly.date(from: s) {
                return date
            }
            
            if let date = DateParsers.iso8601WithFractional.date(from: s) {
                return date
            }

            if let date = DateParsers.iso8601Plain.date(from: s) {
                return date
            }

            if let date = DateParsers.noTZ7Fraction.date(from: s) {
                return date
            }

            if let date = DateParsers.noTZNoFraction.date(from: s) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(s)")
        }

        return d
    }


    public func makeJSONEncoder() -> JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }

    public func makeTokenStore() -> TokenStore {
        KeychainTokenStore(service: "hits.racoon.client")
    }

    public func makeBareHTTPClient() -> HTTPClient {
        let encoder = makeJSONEncoder()
        let decoder = makeJSONDecoder()
        let builder = DefaultRequestBuilder(env: env, encoder: encoder)

        #if DEBUG
        let logger = NetworkLoggerInterceptor(enabled: true)
        return HTTPClient(builder: builder, decoder: decoder, interceptors: [logger])
        #else
        return HTTPClient(builder: builder, decoder: decoder, interceptors: [])
        #endif
    }
    private enum DateParsers {
        static let iso8601Plain: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime]
            return f
        }()
        static let dateOnly: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(secondsFromGMT: 0)
            f.dateFormat = "yyyy-MM-dd"
            return f
        }()

        static let iso8601WithFractional: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return f
        }()
        
        static let noTZ6Fraction: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(secondsFromGMT: 0)
            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            return f
        }()

        static let noTZ7Fraction: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(secondsFromGMT: 0)
            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
            return f
        }()

        static let noTZNoFraction: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(secondsFromGMT: 0)
            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return f
        }()
    }

    public func makeAuthedHTTPClient(
        tokenStore: TokenStore,
        tokenRefresher: any TokenRefresher
    ) -> HTTPClient {
        let encoder = makeJSONEncoder()
        let decoder = makeJSONDecoder()
        let builder = DefaultRequestBuilder(env: env, encoder: encoder)

        let authInterceptor = AuthInterceptor(
            tokenStore: tokenStore,
            refresher: tokenRefresher,
            coordinator: RefreshCoordinator()
        )

        #if DEBUG
        let logger = NetworkLoggerInterceptor(enabled: true)
        return HTTPClient(builder: builder, decoder: decoder, interceptors: [logger, authInterceptor])
        #else
        return HTTPClient(builder: builder, decoder: decoder, interceptors: [authInterceptor])
        #endif
    }
}
