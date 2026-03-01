//
//  Metric.swift
//  Racoon-client
//
//  Created by dark type on 01.03.2026.
//


import SwiftUI

struct Metric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline).monospacedDigit()
        }
    }
}