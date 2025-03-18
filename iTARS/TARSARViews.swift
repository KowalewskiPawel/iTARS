import SwiftUI
import ARKit
import SceneKit

// SwiftUI wrapper for AR View with TARS Manager
struct TARSARView: UIViewRepresentable {
    @ObservedObject var arManager: TARSARManager
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arManager.setupARSession(for: arView)
        
        // Add tap gesture for placing TARS
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update view if needed in the future
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator to handle UI interactions
    class Coordinator: NSObject {
        var parent: TARSARView
        
        init(_ parent: TARSARView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            _ = parent.arManager.handleTap(at: location)
        }
    }
}

// SwiftUI View to display AR placement instructions
struct TARSARInstructionsView: View {
    @ObservedObject var arManager: TARSARManager
    
    var body: some View {
        VStack {
            if !arManager.tarsPlaced {
                Text("Tap on a detected surface to place TARS")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding(.top, 50)
    }
}

// Audio level visualization bar for voice feedback
struct AudioLevelView: View {
    let level: Float
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<20, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(self.barColor(for: index, total: 20))
                        .frame(width: (geometry.size.width - 38) / 20)
                        .scaleEffect(y: self.barHeight(for: index, total: 20), anchor: .bottom)
                }
            }
        }
    }
    
    private func barColor(for index: Int, total: Int) -> Color {
        let threshold = Float(index) / Float(total)
        let isActive = level >= threshold
        
        if threshold < 0.6 {
            return isActive ? .green : Color.green.opacity(0.3)
        } else if threshold < 0.8 {
            return isActive ? .yellow : Color.yellow.opacity(0.3)
        } else {
            return isActive ? .red : Color.red.opacity(0.3)
        }
    }
    
    private func barHeight(for index: Int, total: Int) -> CGFloat {
        let baseHeight: CGFloat = 0.2
        let threshold = Float(index) / Float(total)
        
        if level >= threshold {
            return 1.0
        } else {
            return baseHeight
        }
    }
}
