//
//  Loadable.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


enum Loadable<Value>: Sendable {
    case idle
    case loading
    case loaded(Value)
    case failed(message: String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var value: Value? {
        if case .loaded(let v) = self { return v }
        return nil
    }

    var errorMessage: String? {
        if case .failed(let m) = self { return m }
        return nil
    }
}