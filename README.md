# iTARS - Interstellar TARS in Augmented Reality

## Overview

iTARS is an iOS application that brings the iconic TARS robot from Christopher Nolan's "Interstellar" into the real world through augmented reality. This app combines ARKit for spatial positioning and ElevenLabs' conversational AI to create an interactive TARS assistant that you can place in your environment and have philosophical conversations with.

## Features

- **AR Placement**: Position TARS on any horizontal surface in your environment
- **Voice Conversations**: Speak with TARS using ElevenLabs' advanced conversational AI
- **Movie-Accurate Design**: 3D model inspired by the monolithic rectangular design from the film
- **Animated Responses**: TARS animates while speaking, with visual feedback for different states
- **Spatial Awareness**: TARS can detect and interact with surfaces in your environment

## Technologies Used

- **Swift & SwiftUI**: App architecture and UI components
- **ARKit & SceneKit**: AR tracking and 3D rendering
- **ElevenLabs Conversational AI SDK**: Voice-based AI interactions
- **AVFoundation**: Audio handling
- **Speech**: Speech recognition

## Requirements

- iOS 16.0+
- iPhone with A12 Bionic chip or later (for ARKit)
- Xcode 14.0+
- Active internet connection for AI conversations
- ElevenLabs API account

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/ARPLearn/iTARS.git
cd iTARS
```

### 2. Install Dependencies

Open the project in Xcode and resolve any package dependencies.

### 3. Configure ElevenLabs

You need an ElevenLabs agent ID to use the voice conversation features:

1. Create an account at [ElevenLabs](https://elevenlabs.io)
2. Create a new Conversational AI agent
3. Configure your agent with a TARS-inspired personality
4. Copy your agent ID
5. Open `TARSVoiceManager.swift` and replace the placeholder agent ID:

```swift
// Line 139 in TARSVoiceControlView.swift
private let tarsAgentId = "YOUR_AGENT_ID_HERE"
```

**Note:** The agent ID is the only configuration you need to change to get the ElevenLabs integration working.

### 4. Build and Run

Build the project in Xcode and run it on your iOS device.

## Usage

1. **Launch the App**: Open iTARS on your device
2. **Scan Environment**: Move your device to scan horizontal surfaces
3. **Place TARS**: Tap on a detected surface to place TARS
4. **Connect to Voice AI**: Tap the connection button to connect to ElevenLabs
5. **Start Conversation**: Tap the microphone button and speak to TARS
6. **Try Philosophical Questions**: For the best experience, ask TARS philosophical questions about existence, consciousness, and purpose

## Conversation Ideas

TARS is designed to excel at philosophical conversations. Try questions like:

- "TARS, when you're not being observed in AR, do you think you continue to exist?"
- "What's your take on Plato's Cave allegory as someone who exists in augmented reality?"
- "Do you think digital consciousness experiences time differently than human consciousness?"
- "If your code were copied into another instance, would that be you, your twin, or something else entirely?"
- "From your perspective, what is the most beautiful thing about human existence?"

## Project Structure

- **iTARSApp.swift**: Main application entry point
- **TARSContainerView.swift**: Main container view coordinating AR and voice components
- **TARSARManager.swift**: Manages AR functionality and TARS 3D model
- **TARSARViews.swift**: SwiftUI wrappers for AR views
- **TARSVoiceManager.swift**: Handles ElevenLabs AI integration
- **TARSVoiceControlView.swift**: UI for voice interactions

## Troubleshooting

- **AR Placement Issues**: Ensure you're in a well-lit environment with distinct features
- **Voice Connection Problems**: Check your internet connection and verify your ElevenLabs agent ID is correct
- **App Crashes**: Make sure you've granted microphone and camera permissions

## Acknowledgments

- Inspired by TARS from Christopher Nolan's "Interstellar"
- Special thanks to ElevenLabs for their Conversational AI API
- AR implementation based on Apple's ARKit documentation

## License

This project is licensed under the MIT License - see the LICENSE file for details.
