//
//  LoginView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 32) {
            header
            
            submitButton

            Spacer(minLength: 0)
        }
        .padding(20)
        .navigationTitle("Sign in")
        .navigationBarTitleDisplayMode(.large)
        .errorAlert(errorMessage: viewModel.state.errorMessage, clearError: { viewModel.clearError() })
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome")
                .font(.title2).bold()
            Text("Sign in using your organization's SSO.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var submitButton: some View {
        Button {
            Task { await viewModel.submit() }
        } label: {
            HStack {
                if viewModel.state.isLoading {
                    ProgressView().controlSize(.small)
                        .padding(.trailing, 4)
                }
                Text(viewModel.state.isLoading ? "Opening browser..." : "Sign in with SSO")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: !viewModel.state.isLoading))
        .disabled(viewModel.state.isLoading)
    }
}
