//
//  MainFlowView.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct MainFlowView: View {
    var body: some View {
        TabView {
            AccountsFlowView()
                .tabItem { Label("Accounts", systemImage: "creditcard") }

            CreditsFlowView()
                .tabItem { Label("Credits", systemImage: "banknote") }

            ProfileFlowView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}