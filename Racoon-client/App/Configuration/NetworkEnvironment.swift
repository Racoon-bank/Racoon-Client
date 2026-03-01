//
//  NetworkEnvironment.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//

import Foundation

public struct NetworkEnvironment: Sendable {
    public let coreBaseURL: URL
    public let infoBaseURL: URL
    public let creditBaseURL: URL

    public init(coreBaseURL: URL, infoBaseURL: URL, creditBaseURL: URL) {
        self.coreBaseURL = coreBaseURL
        self.infoBaseURL = infoBaseURL
        self.creditBaseURL = creditBaseURL
    }

    public func baseURL(for service: APIService) -> URL {
        switch service {
        case .core: return coreBaseURL
        case .info: return infoBaseURL
        case .credit: return creditBaseURL
        }
    }

    public static func fromBuildConfig() -> NetworkEnvironment {
        NetworkEnvironment(
            coreBaseURL: URL(string: "https://core.hits-playground.ru")!,
            infoBaseURL: URL(string: "https://info.hits-playground.ru")!,
            creditBaseURL: URL(string: "https://credit.hits-playground.ru")!
        )
    }
}
