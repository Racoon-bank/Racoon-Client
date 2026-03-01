//
//  AsyncViewState.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

@MainActor
enum AsyncViewState: Equatable {
    case idle
    case loading
    case success
    case error(message: String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}