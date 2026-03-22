//
//  DomainError.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


public enum DomainError: Error, Sendable {
    case unauthorized
    case forbidden
    case noInternet
    case timeout
    case serverUnavailable
    case unknown
}