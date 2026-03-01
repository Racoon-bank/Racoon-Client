//
//  HTTPError.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public enum NetworkError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case unauthorized
    case httpStatus(code: Int, body: Data)
    case decoding(Error)
    case emptyBody
}
