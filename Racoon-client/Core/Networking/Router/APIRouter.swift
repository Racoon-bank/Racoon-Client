//
//  APIRouter.swift
//  Racoon-client
//
//  Created by dark type on 26.02.2026.
//


public protocol APIRouter: Sendable {
    var endpoint: Endpoint { get }
}