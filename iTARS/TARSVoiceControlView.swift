//
//  TARSVoiceControlView.swift
//  iTARS
//
//  Created by Pawel Kowalewski on 17/03/2025.
//

import SwiftUI
import ElevenLabsSDK

// Voice control interface for TARS
struct TARSVoiceControlView: View {
    @ObservedObject var voiceManager: TARSVoiceManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Connection status indicator
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
            
            // Message display
            if !voiceManager.lastMessage.isEmpty {
                Text(voiceManager.lastMessage)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            HStack(spacing: 25) {
                // Microphone control
                Button(action: {
                    if voiceManager.conversationStatus == .connected {
                        if voiceManager.conversationMode == .listening {
                            voiceManager.stopListening()
                        } else {
                            voiceManager.startListening()
                        }
                    } else {
                        voiceManager.startConversation()
                    }
                }) {
                    Image(systemName: buttonIcon)
                        .font(.system(size: 30))
                        .padding()
                        .background(buttonColor)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            .padding(.bottom, 30)
            
            // Audio level visualization
            AudioLevelView(level: voiceManager.audioLevel)
                .frame(height: 20)
                .padding(.horizontal)
        }
        .padding(.bottom, 50)
    }
    
    // Helper computed properties for UI
    private var statusColor: Color {
        switch voiceManager.conversationStatus {
        case .connected:
            return .green
        case .connecting:
            return .yellow
        case .disconnected:
            return .red
        @unknown default:
            return .gray
        }
    }
    
    private var statusText: String {
        switch voiceManager.conversationStatus {
        case .connected:
            return "TARS Online"
        case .connecting:
            return "TARS Connecting..."
        case .disconnected:
            return "TARS Offline"
        @unknown default:
            return "Unknown Status"
        }
    }
    
    private var buttonIcon: String {
        if voiceManager.conversationStatus != .connected {
            return "power"
        }
        
        return voiceManager.conversationMode == .listening ? "mic.fill" : "mic"
    }
    
    private var buttonColor: Color {
        if voiceManager.conversationStatus != .connected {
            return .blue
        }
        
        return voiceManager.conversationMode == .listening ? .red : .blue
    }
}
