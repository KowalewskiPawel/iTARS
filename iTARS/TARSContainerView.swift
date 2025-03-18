//
//  ContentView.swift
//  iTARS
//
//  Created by Pawel Kowalewski on 17/03/2025.
//

import SwiftUI
import ARKit
import Speech

struct TARSContainerView: View {
    // Create the state objects for our managers
        @StateObject private var arManager = TARSARManager()
        @StateObject private var voiceManager: TARSVoiceManager
        
        // Initialize with connected managers
        init() {
            // Create AR manager
            let arManager = TARSARManager()
            self._arManager = StateObject(wrappedValue: arManager)
            
            // Create voice manager with reference to AR manager for animations
            self._voiceManager = StateObject(wrappedValue: TARSVoiceManager(arManager: arManager))
        }
        
        var body: some View {
            ZStack {
                // AR View layer
                TARSARView(arManager: arManager)
                    .edgesIgnoringSafeArea(.all)
                
                // AR placement instructions if needed
                if !arManager.tarsPlaced {
                    TARSARInstructionsView(arManager: arManager)
                }
                
                // Voice controls at the bottom
                VStack {
                    Spacer()
                    TARSVoiceControlView(voiceManager: voiceManager)
                }
            }
            .onAppear {
                // Request necessary permissions
                requestPermissions()
            }
        }
        
        // Request permissions needed for the app
        private func requestPermissions() {
            // Microphone permission
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                print("Microphone permission granted: \(granted)")
            }
            
            // Speech recognition permission
            SFSpeechRecognizer.requestAuthorization { status in
                print("Speech recognition authorization status: \(status.rawValue)")
            }
        }
    }

    // Preview provider for SwiftUI canvas
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            TARSContainerView()
        }
    }
