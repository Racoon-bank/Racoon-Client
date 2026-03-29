//
//  HiddenAccountsStorage.swift
//  Racoon-client
//
//  Created by dark type on 30.03.2026.
//

import Foundation

public protocol HiddenAccountsStorage: Sendable {
    func getHiddenAccountIds() -> Set<UUID>
    func saveHiddenAccountIds(_ ids: Set<UUID>)
    func addHiddenAccount(id: UUID)
    func removeHiddenAccount(id: UUID)
}

public final class UserDefaultsHiddenAccountsStorage: HiddenAccountsStorage, @unchecked Sendable {
    private let defaults: UserDefaults
    private let key = "hidden_bank_account_ids"
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    public func getHiddenAccountIds() -> Set<UUID> {
        guard let strings = defaults.stringArray(forKey: key) else { return [] }
        return Set(strings.compactMap { UUID(uuidString: $0) })
    }
    
    public func saveHiddenAccountIds(_ ids: Set<UUID>) {
        let strings = ids.map { $0.uuidString }
        defaults.set(strings, forKey: key)
    }
    
    public func addHiddenAccount(id: UUID) {
        var current = getHiddenAccountIds()
        current.insert(id)
        saveHiddenAccountIds(current)
    }
    
    public func removeHiddenAccount(id: UUID) {
        var current = getHiddenAccountIds()
        current.remove(id)
        saveHiddenAccountIds(current)
    }
}
