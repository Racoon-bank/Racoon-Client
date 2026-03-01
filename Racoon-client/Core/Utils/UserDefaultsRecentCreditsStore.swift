//
//  UserDefaultsRecentCreditsStore.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Foundation

public actor UserDefaultsRecentCreditsStore: RecentCreditsStore {

    private let key: String
    private let maxCount: Int

    public init(
        key: String = "recent_credit_ids",
        maxCount: Int = 10
    ) {
        self.key = key
        self.maxCount = maxCount
    }

    public func load() async -> [Int64] {
        let defaults = UserDefaults.standard
        return (defaults.array(forKey: key) as? [NSNumber])?
            .map { $0.int64Value } ?? []
    }

    public func add(_ id: Int64) async {
        let defaults = UserDefaults.standard

        var items = await load()
        items.removeAll { $0 == id }
        items.insert(id, at: 0)

        if items.count > maxCount {
            items = Array(items.prefix(maxCount))
        }

        defaults.set(items.map { NSNumber(value: $0) }, forKey: key)
    }

    public func remove(_ id: Int64) async {
        let defaults = UserDefaults.standard

        var items = await load()
        items.removeAll { $0 == id }

        defaults.set(items.map { NSNumber(value: $0) }, forKey: key)
    }

    public func clear() async {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
    }
}
