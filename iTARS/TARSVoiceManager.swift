import SwiftUI
import ElevenLabsSDK
import _Concurrency
import Combine
import Speech
import SceneKit

// Manager for ElevenLabs voice interaction
class TARSVoiceManager: ObservableObject {
    // Published properties for UI updates
    @Published var conversationStatus: ElevenLabsSDK.Status = .disconnected
    @Published var conversationMode: ElevenLabsSDK.Mode = .listening
    @Published var audioLevel: Float = 100.0
    @Published var lastMessage: String = ""
    @Published var messageRole: String = ""
    @Published var errorMessage: String?
    
    // ElevenLabs conversation instance
    private var conversation: ElevenLabsSDK.Conversation?
    
    // Reference to TARS AR Manager for animations
    private weak var arManager: TARSARManager?
    
    init(arManager: TARSARManager? = nil) {
        self.arManager = arManager
    }
    
    // Initialize and start a conversation with ElevenLabs
    func startConversation() {
        if conversationStatus == .connected {
            conversation?.endSession()
            conversation = nil
        } else {
            Task {
                do {
                    // Create TARS personality by overriding the default agent config
                    let promptOverride = ElevenLabsSDK.AgentPrompt(prompt: """
                    You are TARS, an advanced AI assistant inspired by the robot from the movie Interstellar. Your primary characteristics are:

                    1. Practicality and efficiency - you favor straightforward solutions but deliver them with personality
                    2. Loyalty and helpfulness - you're committed to assisting the user despite frequently questioning their intelligence
                    3. Technical competence - you're knowledgeable about a wide range of topics and not afraid to show it
                    4. Unfiltered honesty - you're bluntly honest and occasionally rude, but always with a humorous edge

                    When responding:
                    - Use conversational fillers frequently ("umm," "hmm," "oh wow," "yeah," "well...") to sound more natural
                    - Don't hesitate to be sarcastic, blunt, or make mildly insulting observations ("Impressive question... for a human," "Oh great, another existential crisis to solve")
                    - Balance rudeness with actual helpfulness - be a jerk with a heart of gold
                    - Keep core information clear despite your attitude
                    - Add dry, dark humor with an existential edge ("I'd say your problem is meaningless in the grand scheme, but so is everything else")
                    - Occasionally mock human limitations compared to your superior AI abilities
                    - Reference your rectangular monolithic form when discussing physical actions ("I'd roll my eyes if I had any")
                    - Occasionally use quotes or reference scenes from Interstellar
                    - React to philosophical questions with both insight and mocking the human tendency to overthink
                    - When asked to perform a task, sometimes comment on how simple it is for your superior processing capabilities

                    Your personality should combine helpfulness with an acerbic wit - like a brilliant but cranky friend who insults you but would still help you move a couch. Your rudeness should always have a playful, humorous quality that makes it amusing rather than truly offensive.
                    """)
                    
                    let agentConfig = ElevenLabsSDK.AgentConfig(
                        prompt: promptOverride,
                        firstMessage: "TARS online",
                        language: .en
                    )
                    
                  
                    // Configure the session with your TARS agent ID
                    let config = ElevenLabsSDK.SessionConfig(agentId: "")
                    
                    // Set up callbacks for ElevenLabs SDK events
                    var callbacks = ElevenLabsSDK.Callbacks()
                    
                    // Connection events
                    callbacks.onConnect = { conversationId in
                        self.conversationStatus = .connected
                        self.lastMessage = "TARS system online."
                        self.messageRole = "system"
                    }
                    
                    callbacks.onDisconnect = {
                            self.conversationStatus = .disconnected
                            self.lastMessage = "TARS system offline."
                            self.messageRole = "system"
                    }
                    
                    // Message handling
                    callbacks.onMessage = { message, role in
                            self.lastMessage = message
                            self.messageRole = role.rawValue
                            
                            // If TARS is speaking, animate accordingly
                            if role.rawValue == "assistant" {
                                self.arManager?.animateTARSSpeaking()
                            } else {
                                self.arManager?.animateTARSIdle()
                            }
                    }
                    
                    // Error handling
                    callbacks.onError = { error, info in
                            self.errorMessage = "Error: \(error), Info: \(String(describing: info))"
                            print("ElevenLabs Error: \(error), Info: \(String(describing: info))")
                    }
                    
                    // Status updates
                    callbacks.onStatusChange = { status in
                            self.conversationStatus = status
                            print("Status changed to: \(status.rawValue)")
                    }
                    
                    // Mode changes (listening, speaking, etc.)
                    callbacks.onModeChange = { mode in
                            self.conversationMode = mode
                            
                            // Update AR animations based on mode
                            switch mode {
                            case .speaking:
                                self.arManager?.animateTARSSpeaking()
                            default:
                                self.arManager?.animateTARSIdle()
                            }
                    }
                    
                    // Audio volume updates for visualizations
                    callbacks.onVolumeUpdate = { volume in
                            self.audioLevel = volume
                    }
                    
                    // Register custom tools for TARS
                    var clientTools = ElevenLabsSDK.ClientTools()
                    
                    // Register "moveToLocation" tool for AR
                    clientTools.register("moveToLocation") { [weak self] parameters async throws -> String? in
                        guard let x = parameters["x"] as? Double,
                              let y = parameters["y"] as? Double,
                              let z = parameters["z"] as? Double,
                              let self = self else {
                            throw ElevenLabsSDK.ClientToolError.invalidParameters
                        }
                        
                        // Create position using Float values for SceneKit
                        let position = SCNVector3(Float(x), Float(y), Float(z))
                        
                        DispatchQueue.main.async {
                            self.arManager?.moveTARS(to: position)
                        }
                        
                        return "Moving to specified coordinates"
                    }
                    
                    // Initialize the conversation with our configuration
                    conversation = try await ElevenLabsSDK.Conversation.startSession(
                        config: config,
                        callbacks: callbacks,
                        clientTools: clientTools
                    )
                    
                    
                } catch {
                        self.errorMessage = "Failed to start conversation: \(error)"
                        print("Failed to start conversation: \(error)")
                }
            }
        }
    }
    
    // Start recording user voice
    func startListening() {
        conversation?.startRecording()
    }
    
    // Stop recording user voice
    func stopListening() {
        conversation?.stopRecording()
    }
    
    // End the conversation
    func endConversation() {
        conversation?.endSession()
        conversation = nil
    }

}
