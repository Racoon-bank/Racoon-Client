//
//  BankHubClient.swift
//  Racoon-client
//
//  Created by dark type on 22.03.2026.
//


import Foundation

private struct SignalRMessage<T: Decodable>: Decodable {
    let type: Int?
    let target: String?
    let arguments: [T]?
}

public actor BankHubClient {
    private var task: URLSessionWebSocketTask?
    private let session: URLSession
    private let env: NetworkEnvironment
    private let tokenStore: TokenStore
    private let eventBus: DomainEventBus
    
    private let recordSeparator = Character(UnicodeScalar(0x1E)).description

    public init(env: NetworkEnvironment, tokenStore: TokenStore, eventBus: DomainEventBus, session: URLSession = .shared) {
        self.env = env
        self.tokenStore = tokenStore
        self.eventBus = eventBus
        self.session = session
    }

    public func connect() async {
        guard task == nil else { return }
        
        guard let tokens = await tokenStore.readTokens() else {
            print("⚠️ Cannot connect to WS: No auth token")
            return
        }

        let wsURLString = "wss://core.hits-playground.ru/ws?access_token=\(tokens.accessToken)"
        guard let url = URL(string: wsURLString) else { return }
        
       
        let wsTask = session.webSocketTask(with: url)
        
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
         let idString = accountId.uuidString.lowercased()
         
         let message = """
         {"type":1,"target":"SubscribeToAccount","arguments":["\(idString)"]}
         """
         try await sendMessage(message)
     }

    public func unsubscribeFromAccount(accountId: UUID) async throws {
         let idString = accountId.uuidString.lowercased()
         
         let message = """
         {"type":1,"target":"UnsubscribeFromAccount","arguments":["\(idString)"]}
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
          let messages = text.components(separatedBy: recordSeparator).filter { !$0.isEmpty }
          let decoder = JSONDecoder()
          
          for msg in messages {
              print("📥 RAW WS Message: \(msg)")
              
              if msg == "{}" || msg == "{\"type\":6}" { continue }
              
              guard let data = msg.data(using: .utf8) else { continue }
              
              do {
                  let signalRMsg = try decoder.decode(SignalRMessage<OperationCreatedPayload>.self, from: data)
                  
                  if signalRMsg.type == 1,
                     signalRMsg.target == "OperationCreated",
                     let payload = signalRMsg.arguments?.first {
                      
                      print("🎉 WS Received update for account: \(payload.accountId)")
                      
                      Task {
                          await eventBus.publish(.accountUpdated(accountId: payload.accountId))
                      }
                  }
              } catch {
              
              }
          }
      }
}
