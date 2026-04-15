//
//  MonitoringInterceptor.swift
//  Racoon-client
//
//  Created by dark type on 15.04.2026.
//

import Foundation

public final class MonitoringInterceptor: HTTPInterceptor {
    private let batcher = MonitoringBatcher()
    private let serviceName: String
    
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    public init(serviceName: String = "Racoon-Client") {
        self.serviceName = serviceName
    }
    
    public func requestCompleted(_ request: URLRequest, response: HTTPURLResponse, data: Data, durationMs: Int) async {
        await logToBatcher(request: request, statusCode: response.statusCode, durationMs: durationMs, errorMsg: "Success")
    }
    
    public func requestFailed(_ request: URLRequest, error: NetworkError, durationMs: Int) async {
        let statusCode: Int
        let msg: String
        
        switch error {
        case .httpStatus(let code, _):
            statusCode = code
            msg = "HTTP Status Error"
        case .unauthorized:
            statusCode = 401
            msg = "Unauthorized"
        case .transport(let err):
            statusCode = (err as NSError).code
            msg = err.localizedDescription
        default:
            statusCode = 0
            msg = String(describing: error)
        }
        
        await logToBatcher(request: request, statusCode: statusCode, durationMs: durationMs, errorMsg: msg)
    }
    
    private func logToBatcher(request: URLRequest, statusCode: Int, durationMs: Int, errorMsg: String) async {
        guard let urlString = request.url?.absoluteString, !urlString.contains("monitoring.hits-playground.ru") else {
            return
        }
        
        let traceId = request.value(forHTTPHeaderField: "Idempotency-Key") ?? UUID().uuidString
        
        let log = MonitoringLogPayload(
            serviceName: serviceName,
            path: request.url?.path ?? "/",
            method: request.httpMethod ?? "GET",
            statusCode: statusCode,
            durationMs: durationMs,
            traceId: traceId,
            createdAt: isoFormatter.string(from: Date()),
            message: errorMsg,
            isDuplicate: false
        )
        
        await batcher.addLog(log)
    }
}
