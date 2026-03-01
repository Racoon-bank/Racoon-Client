//
//  Endpoint.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct Endpoint: Sendable {
    public let service: APIService
    public let method: HTTPMethod
    public let path: String
    public var query: [URLQueryItem] = []
    public var headers: [String: String] = [:]
    public var body: HTTPBody = .none

    public init(
        service: APIService,
        method: HTTPMethod,
        path: String,
        query: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: HTTPBody = .none
    ) {
        self.service = service
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
    }
}
