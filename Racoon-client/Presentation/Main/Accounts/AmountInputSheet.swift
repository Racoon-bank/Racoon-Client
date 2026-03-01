//
//  AmountInputSheet.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import SwiftUI

struct AmountInputSheet: View {
    let title: String
    let confirmTitle: String
    let onConfirm: (Decimal) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Amount", text: $text)
                        .keyboardType(.decimalPad)
                } footer: {
                    if let errorText {
                        Text(errorText).foregroundStyle(.red)
                    } else {
                        Text("Enter a positive amount.")
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(confirmTitle) {
                        guard let amount = parseDecimal(text), amount > 0 else {
                            errorText = "Invalid amount"
                            return
                        }
                        onConfirm(amount)
                        dismiss()
                    }
                }
            }
        }
    }

    private func parseDecimal(_ s: String) -> Decimal? {
        
        let normalized = s.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }
}
