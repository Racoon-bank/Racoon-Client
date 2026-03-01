//
//  AccountsFlowView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct AccountsFlowView: View {
    @Environment(\.appContainer) private var container

    var body: some View {
        NavigationStack {
            let factory = ViewModelFactory(container: container)
            AccountsListView(viewModel: factory.makeAccountsListViewModel())
        }
    }
}
