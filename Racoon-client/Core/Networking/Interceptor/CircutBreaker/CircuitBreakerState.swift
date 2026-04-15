//
//  CircuitBreakerState.swift
//  Racoon-client
//
//  Created by dark type on 15.04.2026.
//


public actor CircuitBreakerState {
    private var retryCounts: [String: Int] = [:]
    
    func incrementAndCheck(id: String) -> Bool {
        let current = retryCounts[id, default: 0]
        if current >= 3 {
            retryCounts[id] = nil
            return false
        }
        retryCounts[id] = current + 1
        return true
    }
    
    func clear(id: String) {
        retryCounts[id] = nil
    }
}
