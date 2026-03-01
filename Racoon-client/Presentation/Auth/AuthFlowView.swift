//
//  AuthFlowView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

import SwiftUI

struct AuthFlowView: View {
    @Environment(\.appContainer) private var container
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            let factory = ViewModelFactory(container: container)
            AuthLandingView(
                loginViewModel: factory.makeLoginViewModel(appState: appState),
                registerViewModel: factory.makeRegisterViewModel(appState: appState)
            )
        }
    }
}
