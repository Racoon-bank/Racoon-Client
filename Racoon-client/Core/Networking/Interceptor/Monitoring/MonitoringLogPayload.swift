//
//  MonitoringLogPayload.swift
//  Racoon-client
//
//  Created by dark type on 15.04.2026.
//


public struct MonitoringLogPayload: Encodable, Sendable {
    public let serviceName: String
    public let path: String
    public let method: String
    public let statusCode: Int
    public let durationMs: Int
    public let traceId: String
    public let createdAt: String
    public let message: String
    public let isDuplicate: Bool
}
