//
//  CreditsHomeView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI


struct CreditsHomeView: View {
    @StateObject private var viewModel: CreditsHomeViewModel
    @Environment(\.appContainer) private var container

    @State private var showTakeSheet = false
    @State private var destination: CreditNav?

    init(viewModel: CreditsHomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            heroSection
            myCreditsSection
            recentSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Credits")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showTakeSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Take credit")
            }

            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.state.isLoading {
                    ProgressView().controlSize(.small)
                }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.refresh() }
        .sheet(isPresented: $showTakeSheet, content: takeCreditSheet)
        .navigationDestination(item: $destination, destination: creditDestination)
        .alert("Error", isPresented: errorPresentedBinding, actions: errorAlertActions, message: errorAlertMessage)
    }
}

private extension CreditsHomeView {
    var heroSection: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "creditcard")
                    .font(.title2)
                    .foregroundStyle(.tint)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Your credits")
                        .font(.headline)
                    Text("Track remaining balance, payments, and due dates.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 6)
        }
    }

    var myCreditsSection: some View {
        Section("My credits") {
            if viewModel.myCredits.isEmpty {
                emptyState
            } else {
                let active = viewModel.myCredits.filter { $0.status != .paidOff && $0.status != .cancelled }
                let closed = viewModel.myCredits.filter { $0.status == .paidOff || $0.status == .cancelled }

                if !active.isEmpty {
                    Section("Active") {
                        ForEach(active) { credit in
                            Button { destination = CreditNav(id: credit.id) } label: {
                                CreditRowView(credit: credit)
                            }
                        }
                    }
                }

                if !closed.isEmpty {
                    Section("Closed") {
                        ForEach(closed) { credit in
                            Button { destination = CreditNav(id: credit.id) } label: {
                                CreditRowView(credit: credit)
                            }
                        }
                    }
                }
            }
        }
    }

    var recentSection: some View {
        Section("Recently opened") {
            if viewModel.recentCreditIds.isEmpty {
                Text("No recent credits.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.recentCreditIds, id: \.self) { id in
                    Button {
                        destination = CreditNav(id: id)
                    } label: {
                        HStack {
                            Text("Credit")
                            Spacer()
                            Text("#\(id)")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) { Task { await viewModel.removeRecent(id) } } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }

                Button(role: .destructive) {
                    Task { await viewModel.clearRecents() }
                } label: {
                    Text("Clear recents")
                }
            }
        }
    }

    var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No active credits")
                .font(.headline)
            Text("Take a credit to see it here.")
                .foregroundStyle(.secondary)

            Button {
                showTakeSheet = true
            } label: {
                Text("Take a credit")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}
// MARK: - Sheet
private extension CreditsHomeView {
    func takeCreditSheet() -> some View {
        let factory = ViewModelFactory(container: container)
        return TakeCreditSheet(
            viewModel: factory.makeTakeCreditSheetViewModel()
        ) { input in
            Task {
                if let id = await viewModel.createCredit(
                    bankAccountId: input.bankAccountId,
                    tariffId: input.tariffId,
                    amount: input.amount,
                    durationMonths: input.durationMonths
                ) {
                    destination = CreditNav(id: id)
                }
            }
        }
    }
}

// MARK: - Destination
private extension CreditsHomeView {
    func creditDestination(_ nav: CreditNav) -> some View {
        let factory = ViewModelFactory(container: container)
        return CreditDetailsView(
            viewModel: factory.makeCreditDetailsViewModel(creditId: nav.id),
            creditId: nav.id
        )
        .task { await viewModel.markOpened(nav.id) }
    }
}

// MARK: - Alert
private extension CreditsHomeView {
    var errorPresentedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.errorMessage != nil },
            set: { isPresented in if !isPresented { viewModel.clearError() } }
        )
    }

    func errorAlertActions() -> some View {
        Button("OK", role: .cancel) { viewModel.clearError() }
    }

    func errorAlertMessage() -> some View {
        Text(viewModel.state.errorMessage ?? "")
    }

    func money(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }
}

private struct CreditNav: Identifiable, Hashable {
    let id: Int64
}
