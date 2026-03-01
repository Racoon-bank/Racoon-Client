//
//  LoginView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel

    private enum Field: Hashable {
        case email
        case password
    }

    @FocusState private var focusedField: Field?

    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            header

            VStack(spacing: 12) {
                emailField
                passwordField
            }

            submitButton

            Spacer(minLength: 0)
        }
        .padding(20)
        .navigationTitle("Sign in")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { focusedField = .email }
        .alert("Error", isPresented: Binding(
            get: { viewModel.state.errorMessage != nil },
            set: { newValue in if !newValue { viewModel.clearError() } }
        )) {
            Button("OK", role: .cancel) { viewModel.clearError() }
        } message: {
            Text(viewModel.state.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome back")
                .font(.title2).bold()
            Text("Use your account credentials to continue.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emailField: some View {
        TextField("Email", text: $viewModel.email)
            .textContentType(.username)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .focused($focusedField, equals: .email)
            .onSubmit { focusedField = .password }
            .textFieldStyle(.roundedBorder)
    }

    private var passwordField: some View {
        SecureField("Password", text: $viewModel.password)
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .submitLabel(.go)
            .focused($focusedField, equals: .password)
            .onSubmit { Task { await viewModel.submit() } }
            .textFieldStyle(.roundedBorder)
    }

    private var submitButton: some View {
        Button {
            Task { await viewModel.submit() }
        } label: {
            HStack {
                if viewModel.state.isLoading {
                    ProgressView().controlSize(.small)
                }
                Text(viewModel.state.isLoading ? "Signing in..." : "Sign in")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.canSubmit))
        .disabled(!viewModel.canSubmit)
    }
}
