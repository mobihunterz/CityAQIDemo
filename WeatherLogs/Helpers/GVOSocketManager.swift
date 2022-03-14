//
//  SocketManager.swift
//  WebSocketTracker
//
//  Created by Douglas Barbosa on 27/05/17.
//  Copyright © 2017 Douglas Barbosa. All rights reserved.
//

import UIKit
import Starscream

class GVOWebsocketHandler<T: Codable> : NSObject {
    
    // MARK: - Properties
    
    var manager: WebSocket!
    
    private var heartbeater: Timer?
    private var restarter: Timer?
    
    // MARK: - Event handlers
    var didConnectHandler: (() -> Void)?
    var didDisconnectHandler: (() -> Void)?
    
    var didResponseHandler: (([T]) -> Void)?
    
    // MARK: - Constructor
    override init() {
        super.init()
        
        guard let websocketUrl = URL(string: "ws://city-ws.herokuapp.com") else {
            return
        }
        
        var request = URLRequest(url: websocketUrl)
        request.timeoutInterval = 30.0
        manager = WebSocket(request: request)
    }
    
    // MARK: - Socket event handlers
    
    @objc func establishConnection() {
        
        manager.onEvent = { [weak self] event in
            
            switch event {
            case .connected(let headers):
                self?.websocketDidConnectHandler(event, with: headers)
                
            case .disconnected(let reason, let code):
                self?.websocketDidDisconnectHandler(event, with: reason, and: code)
                
            case .text(let string):
                self?.websocketResponseHandler(event, with: string)
                
            default:
                print("Handle other events to reconnect and more...")
            }
        }
        
        manager.connect()
    }
    
    private func websocketDidConnectHandler(_ event: WebSocketEvent, with headers: [String: String]) {
        print("websocket is connected: \(headers)")
        didConnectHandler?()
    }
    
    private func websocketDidDisconnectHandler(_ event: WebSocketEvent, with reason: String, and code: UInt16) {
        heartbeater?.invalidate()
        heartbeater = nil
        
        restarter?.invalidate()
        restarter = nil
        
        print("websocket is disconnected: \(reason) with code: \(code)")
        didDisconnectHandler?()
    }
    
    private func websocketResponseHandler(_ event: WebSocketEvent, with response: String) {
        
        let decoder = JSONDecoder()
        do {
            let data = response.data(using: .utf8)!
            let eventResponse = try decoder.decode([T].self, from: data)
            print(eventResponse)
            
            didResponseHandler?(eventResponse)
        } catch {
            print(error)
        }
    }
    
    func closeConnection() {
        manager.disconnect()
    }
}
