//
//  ErrorAlertModifier.swift
//  Racoon-client
//
//  Created by dark type on 18.03.2026.
//


import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    let errorMessage: String?
    let clearError: () -> Void

    func body(content: Content) -> some View {
        content.alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { newValue in if !newValue { clearError() } }
        )) {
            Button("OK", role: .cancel) { clearError() }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

extension View {
   func errorAlert(errorMessage: String?, clearError: @escaping () -> Void) -> some View {
        self.modifier(ErrorAlertModifier(errorMessage: errorMessage, clearError: clearError))
    }
}
