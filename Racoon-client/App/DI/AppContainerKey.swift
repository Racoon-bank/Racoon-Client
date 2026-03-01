//
//  AppContainerKey.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//

import SwiftUI

private struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppContainer = .shared
}

extension EnvironmentValues {
    var appContainer: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}
