//
//  IdempotencyInterceptor.swift
//  Racoon-client
//
//  Created by dark type on 15.04.2026.
//

import Foundation

public final class IdempotencyInterceptor: HTTPInterceptor {
    public init() {}
    
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var req = request
        
        if let method = req.httpMethod?.uppercased(),
           ["POST", "PUT", "DELETE"].contains(method) {
            if req.value(forHTTPHeaderField: "Idempotency-Key") == nil {
                req.setValue(UUID().uuidString, forHTTPHeaderField: "Idempotency-Key")
            }
        }
        
        return req
    }
}
