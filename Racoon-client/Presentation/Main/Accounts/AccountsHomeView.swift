//
//  AccountsHomeView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct AccountsHomeView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Accounts")
                .font(.title2).bold()
            Text("Accounts list + account details will live here.")
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .navigationTitle("Accounts")
    }
}
