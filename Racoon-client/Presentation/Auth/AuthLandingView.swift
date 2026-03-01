//
//  AuthLandingView.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import SwiftUI

struct AuthLandingView: View {
    @State private var mode: Mode = .login

    let loginViewModel: LoginViewModel
    let registerViewModel: RegisterViewModel

    enum Mode: String, CaseIterable {
        case login = "Sign in"
        case register = "Sign up"
    }

    var body: some View {
        VStack(spacing: 16) {
            Picker("", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.top, 12)

            switch mode {
            case .login:
                LoginView(viewModel: loginViewModel)
            case .register:
                RegisterView(viewModel: registerViewModel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}