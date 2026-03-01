//
//  BankAccountOperationDto.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//

import Foundation

public struct BankAccountOperationDto: Decodable, Sendable {
    public let id: UUID
    public let amount: Double
    public let type: OperationTypeDto
    public let createdAt: Date
}
