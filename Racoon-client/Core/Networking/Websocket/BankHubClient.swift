//
//  BankHubClient.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


import Foundation

public actor BankHubClient {
    private var task: URLSessionWebSocketTask?
    private let session: URLSession
    private let env: NetworkEnvironment
    private let tokenStore: TokenStore
    
    // The SignalR record separator character
    private let recordSeparator = Character(UnicodeScalar(0x1E)).description

    public init(env: NetworkEnvironment, tokenStore: TokenStore, session: URLSession = .shared) {
        self.env = env
        self.tokenStore = tokenStore
        self.session = session
    }

    public func connect() async {
        guard task == nil else { return }
        
        guard let tokens = await tokenStore.readTokens() else {
            print("⚠️ Cannot connect to WS: No auth token")
            return
        }

        // Convert https:// to wss:// or http:// to ws://
        var wsURLString =  "wss://core.hits-playground.ru/ws"
        
        guard let url = URL(string: wsURLString) else { return }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        
        let wsTask = session.webSocketTask(with: request)
        self.task = wsTask
        wsTask.resume()
        
        await performSignalRHandshake(task: wsTask)
        startListening(task: wsTask)
    }

    public func disconnect() {
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
    }

    // MARK: - Hub Methods
    
    public func subscribeToAccount(accountId: UUID) async throws {
        let message = """
        {"type":1,"target":"SubscribeToAccount","arguments":["\(accountId.uuidString)"]}
        """
        try await sendMessage(message)
    }

    public func unsubscribeFromAccount(accountId: UUID) async throws {
        let message = """
        {"type":1,"target":"UnsubscribeFromAccount","arguments":["\(accountId.uuidString)"]}
        """
        try await sendMessage(message)
    }

    // MARK: - Internals

    private func performSignalRHandshake(task: URLSessionWebSocketTask) async {
        let handshake = "{\"protocol\":\"json\",\"version\":1}\(recordSeparator)"
        do {
            try await task.send(.string(handshake))
        } catch {
            print("⚠️ SignalR Handshake failed: \(error)")
        }
    }

    private func sendMessage(_ payload: String) async throws {
        guard let task = task else { return }
        let formattedMessage = payload + recordSeparator
        try await task.send(.string(formattedMessage))
    }

    private func startListening(task: URLSessionWebSocketTask) {
        Task {
            while !Task.isCancelled && self.task == task {
                do {
                    let message = try await task.receive()
                    switch message {
                    case .string(let text):
                        handleIncomingMessage(text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            handleIncomingMessage(text)
                        }
                    @unknown default:
                        break
                    }
                } catch {
                    print("⚠️ WS Disconnected or Error: \(error)")
                    break
                }
            }
        }
    }

    private func handleIncomingMessage(_ text: String) {
        // Strip the record separator
        let messages = text.components(separatedBy: recordSeparator).filter { !$0.isEmpty }
        for msg in messages {
            if msg == "{}" { continue } // Handshake response
            if msg == "{\"type\":6}" { continue } // Ping response
            
            // Here you can decode the incoming JSON to broadcast operations via DomainEventBus
            print("📥 WS Message: \(msg)")
        }
    }
}
