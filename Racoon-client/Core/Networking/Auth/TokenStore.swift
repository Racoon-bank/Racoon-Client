//
//  TokenStore.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


import Foundation

public protocol TokenStore: Sendable {
    func readTokens() async -> AuthTokens?
    func saveTokens(_ tokens: AuthTokens) async
    func clearTokens() async
}
