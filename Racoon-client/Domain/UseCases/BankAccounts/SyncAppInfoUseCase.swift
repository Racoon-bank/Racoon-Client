//
//  SyncAppInfoUseCase.swift
//  Racoon-client
//
//  Created by dark type on 30.03.2026.
//


public protocol SyncAppInfoUseCase: Sendable {
    func callAsFunction() async throws
}

public struct SyncAppInfoUseCaseImpl: SyncAppInfoUseCase {
    private let appRepo: AppRepository
    private let storage: HiddenAccountsStorage
    
    public init(appRepo: AppRepository, storage: HiddenAccountsStorage) {
        self.appRepo = appRepo
        self.storage = storage
    }
    
    public func callAsFunction() async throws {
        let info = try await appRepo.getAppInfo()
        if let hiddenIds = info.hiddenBankAccounts {
            storage.saveHiddenAccountIds(Set(hiddenIds))
        }
    }
}