//
//  RegisterView.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel

    private enum Field: Hashable {
        case username
        case email
        case password
    }

    @FocusState private var focusedField: Field?

    init(viewModel: RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            header

            VStack(spacing: 12) {
                usernameField
                emailField
                passwordField
            }

            submitButton

            Spacer(minLength: 0)
        }
        .padding(20)
        .navigationTitle("Sign up")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { focusedField = .username }
        .alert("Error", isPresented: errorPresentedBinding) {
            Button("OK", role: .cancel) { viewModel.clearError() }
        } message: {
            Text(viewModel.state.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Create an account")
                .font(.title2).bold()
            Text("Register to start using the app.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var usernameField: some View {
        TextField("Username", text: $viewModel.username)
            .textContentType(.nickname)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .focused($focusedField, equals: .username)
            .onSubmit { focusedField = .email }
            .textFieldStyle(.roundedBorder)
    }

    private var emailField: some View {
        TextField("Email (optional)", text: $viewModel.email)
            .textContentType(.emailAddress)
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
            .textContentType(.newPassword)
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
                Text(viewModel.state.isLoading ? "Creating..." : "Create account")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.canSubmit))
        .disabled(!viewModel.canSubmit)
    }

    private var errorPresentedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.errorMessage != nil },
            set: { newValue in if !newValue { viewModel.clearError() } }
        )
    }
}