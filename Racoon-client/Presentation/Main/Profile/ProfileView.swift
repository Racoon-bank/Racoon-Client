//
//  ProfileView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section("User") {
                LabeledContent("Username", value: viewModel.username.isEmpty ? "—" : viewModel.username)
                LabeledContent("Email", value: viewModel.email.isEmpty ? "—" : viewModel.email)
            }

            Section {
                Button(role: .destructive) {
                    Task { await viewModel.signOut() }
                } label: {
                    HStack {
                        if viewModel.state.isLoading { ProgressView().controlSize(.small) }
                        Text(viewModel.state.isLoading ? "Signing out..." : "Sign out")
                    }
                }
                .disabled(viewModel.state.isLoading)
            }
        }
        .navigationTitle("Profile")
        .task { await viewModel.load() }
        .errorAlert(errorMessage: viewModel.state.errorMessage, clearError: { viewModel.clearError() })
    }
}
