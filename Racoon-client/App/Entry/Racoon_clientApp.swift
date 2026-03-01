//
//  Racoon_clientApp.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import SwiftUI

@main
struct Racoon_clientApp: App {
    @StateObject private var appState: AppState
       private let container: AppContainer

       init() {
           let container = AppContainer.shared
           self.container = container
           _appState = StateObject(wrappedValue: AppState(container: container))
       }

       var body: some Scene {
           WindowGroup {
               RootView()
                   .environment(\.appContainer, container)
                   .environmentObject(appState)
           }
       }
   }
