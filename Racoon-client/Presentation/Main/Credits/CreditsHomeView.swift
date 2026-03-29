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
            ratingSection
            
            
            if !viewModel.overduePayments.isEmpty {
                overdueSection
            }
            
            if !viewModel.applications.isEmpty {
                applicationsSection
            }
            
            myCreditsSection
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
    var ratingSection: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Credit Rating: \(viewModel.rating?.score.description ?? "Unknown")")
                        .font(.headline)
                    Text("Level: \(viewModel.rating?.ratingLevel ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 6)
        }
    }
    
    var overdueSection: some View {
        Section("Overdue Payments") {
            ForEach(viewModel.overduePayments, id: \.scheduleId) { (overdue: OverduePayment) in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Credit #\(overdue.creditId)")
                        .font(.headline)
                        .foregroundStyle(.red)
                    Text("Amount due: \(money(overdue.remainingDue))")
                        .font(.subheadline)
                    Text("Overdue by \(overdue.overdueDays) days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    var applicationsSection: some View {
           Section("Applications") {
               ForEach(viewModel.applications, id: \.id) { app in
                   HStack {
                       VStack(alignment: .leading, spacing: 4) {
                           Text(app.tariffName)
                               .font(.headline)
                           Text("\(money(app.amount))")
                               .font(.subheadline)
                               .foregroundStyle(.secondary)
                       }
                       Spacer()
                       Text(app.status.rawValue)
                           .font(.caption)
                           .padding(.horizontal, 8)
                           .padding(.vertical, 4)
                           .background(statusColor(for: app.status).opacity(0.2))
                           .foregroundStyle(statusColor(for: app.status))
                           .clipShape(Capsule())
                   }
                   .padding(.vertical, 4)
               }
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
                        ForEach(active, id: \.id) { credit in
                            Button { destination = CreditNav(id: credit.id) } label: {
                                CreditRowView(credit: credit)
                            }
                        }
                    }
                }
                
                if !closed.isEmpty {
                    Section("Closed") {
                        ForEach(closed, id: \.id) { credit in
                            Button { destination = CreditNav(id: credit.id) } label: {
                                CreditRowView(credit: credit)
                            }
                        }
                    }
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
                Text("Apply for a credit")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Helpers & Navigation
private extension CreditsHomeView {
    func takeCreditSheet() -> some View {
        let factory = ViewModelFactory(container: container)
        return TakeCreditSheet(
            viewModel: factory.makeTakeCreditSheetViewModel()
        ) { input in
            Task {
                await viewModel.createCredit(
                    bankAccountId: input.bankAccountId,
                    tariffId: input.tariffId,
                    amount: input.amount,
                    durationMonths: input.durationMonths
                    // Note: if takeCredit expects currency, update createCredit args accordingly!
                )
            }
        }
    }

    func creditDestination(_ nav: CreditNav) -> some View {
        let factory = ViewModelFactory(container: container)
        return CreditDetailsView(
            viewModel: factory.makeCreditDetailsViewModel(creditId: nav.id),
            creditId: nav.id
        )
    }

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
    
    func statusColor(for status: CreditApplicationStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        }
    }
}

private struct CreditNav: Identifiable, Hashable {
    let id: Int64
}
