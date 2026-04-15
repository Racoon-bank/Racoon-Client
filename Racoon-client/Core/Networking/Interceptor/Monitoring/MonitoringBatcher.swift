//
//  MonitoringBatcher.swift
//  Racoon-client
//
//  Created by dark type on 15.04.2026.
//

import Foundation

public actor MonitoringBatcher {
    private var batch: [MonitoringLogPayload] = []
    private let batchSize = 10
    private let session = URLSession.shared
    
    func addLog(_ log: MonitoringLogPayload) {
        batch.append(log)
        if batch.count >= batchSize {
            flush()
        }
    }
    
    private func flush() {
        let logsToSend = batch
        batch.removeAll()
        
        Task {
            do {
                var request = URLRequest(url: URL(string: "https://monitoring.hits-playground.ru/api/logs/batch")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(logsToSend)
                
                let (_, response) = try await session.data(for: request)
                if let httpRes = response as? HTTPURLResponse, httpRes.statusCode >= 300 {
                    print("⚠️ Monitoring payload rejected with status: \(httpRes.statusCode)")
                } else {
                    print("📊 Monitoring payload successfully sent! (\(logsToSend.count) logs)")
                }
            } catch {
                print("❌ Failed to send monitoring batch: \(error)")
            }
        }
    }
}
