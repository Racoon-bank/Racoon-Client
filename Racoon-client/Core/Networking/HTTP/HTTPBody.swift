//
//  HTTPBody.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public enum HTTPBody: Sendable {
    case none
    case json(any Encodable)

    func encode(using encoder: JSONEncoder) throws -> Data? {
        switch self {
        case .none:
            return nil
        case .json(let encodable):
            return try encoder.encode(AnyEncodable(encodable))
        }
    }
}
