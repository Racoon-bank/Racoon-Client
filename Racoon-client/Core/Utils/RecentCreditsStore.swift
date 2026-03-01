//
//  RecentCreditsStore.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public protocol RecentCreditsStore: Sendable {
    func load() async -> [Int64]
    func add(_ id: Int64) async
    func remove(_ id: Int64) async
    func clear() async
}