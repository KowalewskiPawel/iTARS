import ARKit
import SceneKit
import SwiftUI

// Manager class for AR functionality
class TARSARManager: NSObject, ObservableObject, ARSCNViewDelegate {
    // Published properties for state management
    @Published var isARSessionRunning = false
    @Published var detectedPlanes: [ARPlaneAnchor: SCNNode] = [:]
    @Published var tarsNode: SCNNode?
    @Published var tarsPlaced = false
    @Published var animationState: TARSAnimationState = .idle
    
    // AR Session properties
    var arView: ARSCNView?
    private var configuration = ARWorldTrackingConfiguration()
    
    // TARS animation states
    enum TARSAnimationState {
        case idle
        case speaking
        case thinking
        case moving
        case rotating
    }
    
    // Initialize AR session
    func setupARSession(for view: ARSCNView) {
        arView = view
        arView?.delegate = self
        
        // Enable plane detection
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Enable environment texturing for better realism
        if #available(iOS 16.0, *) {
            configuration.environmentTexturing = .automatic
        }
        
        // Enable lighting
        view.autoenablesDefaultLighting = true
        view.automaticallyUpdatesLighting = true
        
        // Set up debug options for development
        #if DEBUG
        view.debugOptions = [.showFeaturePoints]
        #endif
        
        // Start AR session
        arView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        isARSessionRunning = true
    }
    
    // Place TARS in the scene
    func placeTARS(at position: SCNVector3) -> Bool {
        guard let arView = arView, !tarsPlaced else { return false }
        
        // Create TARS node
        let tarsModelNode = createTARSModel()
        
        // Position TARS at the specified position
        tarsModelNode.position = position
        
        // Add to scene
        arView.scene.rootNode.addChildNode(tarsModelNode)
        tarsNode = tarsModelNode
        tarsPlaced = true
        
        // Initial animation
        animateTARSAppearance(tarsModelNode)
        
        return true
    }
    
    // Create TARS 3D model
    private func createTARSModel() -> SCNNode {
        // Create parent node for TARS
        let parentNode = SCNNode()
        
        // Create main body - monolithic rectangular shape like in the movie
        let mainBody = SCNBox(width: 0.3, height: 0.7, length: 0.1, chamferRadius: 0.01)
        mainBody.firstMaterial?.diffuse.contents = UIColor.darkGray
        mainBody.firstMaterial?.metalness.contents = 0.7  // Metallic look
        mainBody.firstMaterial?.roughness.contents = 0.3  // Slightly polished
        
        // Add lighting highlights
        mainBody.firstMaterial?.lightingModel = .physicallyBased
        
        let mainBodyNode = SCNNode(geometry: mainBody)
        mainBodyNode.name = "TARSMainBody"
        parentNode.addChildNode(mainBodyNode)
        
        // Add segments/divisions to simulate TARS' modular design
        addSegmentDivisions(to: mainBodyNode)
        
        // Add subtle illuminated elements
        addIlluminatedElements(to: mainBodyNode)
        
        return parentNode
    }
    
    // Add segment divisions to create the appearance of movable sections
    private func addSegmentDivisions(to node: SCNNode) {
        guard let box = node.geometry as? SCNBox else { return }
        
        // Create horizontal divisions
        let divisionCount = 4
        let divisionHeight = 0.01
        let bodyHeight = box.height
        let spacing = bodyHeight / CGFloat(divisionCount + 1)
        
        for i in 1...divisionCount {
            let division = SCNBox(width: box.width + 0.001, height: divisionHeight, length: box.length + 0.001, chamferRadius: 0)
            division.firstMaterial?.diffuse.contents = UIColor.black
            
            let divisionNode = SCNNode(geometry: division)
            divisionNode.position.y = Float(-bodyHeight/2 + spacing * CGFloat(i))
            node.addChildNode(divisionNode)
        }
    }
    
    // Add illuminated elements to TARS
    private func addIlluminatedElements(to node: SCNNode) {
        guard let box = node.geometry as? SCNBox else { return }
        
        // Create a horizontal light strip
        let lightStripHeight = 0.02
        let lightStrip = SCNBox(width: box.width * 0.8, height: lightStripHeight, length: 0.001, chamferRadius: 0)
        
        // Create emissive material for the light
        let emissiveMaterial = SCNMaterial()
        emissiveMaterial.diffuse.contents = UIColor.blue.withAlphaComponent(0.7)
        emissiveMaterial.emission.contents = UIColor.blue
        lightStrip.firstMaterial = emissiveMaterial
        
        let lightNode = SCNNode(geometry: lightStrip)
        lightNode.position.z = Float(box.length / 2) + 0.001
        lightNode.position.y = Float(box.height / 4)
        node.addChildNode(lightNode)
        
        // Add subtle pulsing animation to the light
        let pulseAction = SCNAction.sequence([
            SCNAction.scale(to: 1.1, duration: 1.0),
            SCNAction.scale(to: 1.0, duration: 1.0)
        ])
        let continuousPulse = SCNAction.repeatForever(pulseAction)
        lightNode.runAction(continuousPulse)
    }
    
    // Animate TARS appearance
    private func animateTARSAppearance(_ node: SCNNode) {
        // Start with TARS scaled down
        node.scale = SCNVector3(0.1, 0.1, 0.1)
        
        // Scale up with a spring effect
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        node.scale = SCNVector3(1, 1, 1)
        
        SCNTransaction.commit()
    }
    
    // Animate TARS when speaking
    func animateTARSSpeaking() {
        guard let tarsNode = tarsNode, animationState != .speaking else { return }
        
        animationState = .speaking
        
        // Find the light element
        let lightNodes = findNodes(named: "TARSMainBody", in: tarsNode)
            .flatMap { $0.childNodes.filter { $0.geometry is SCNBox && $0.position.z > 0 } }
        
        // Pulse the light more rapidly when speaking
        for lightNode in lightNodes {
            lightNode.removeAllActions()
            
            let speakingPulse = SCNAction.sequence([
                SCNAction.scale(to: 1.2, duration: 0.3),
                SCNAction.scale(to: 0.9, duration: 0.3)
            ])
            let continuousSpeakingPulse = SCNAction.repeatForever(speakingPulse)
            lightNode.runAction(continuousSpeakingPulse)
            
            // Also change color to indicate speaking
            if let material = lightNode.geometry?.firstMaterial {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = UIColor.cyan
                material.diffuse.contents = UIColor.cyan.withAlphaComponent(0.7)
                SCNTransaction.commit()
            }
        }
        
        // Subtle movement to indicate speech
        let subtleRotation = SCNAction.sequence([
            SCNAction.rotateBy(x: 0, y: 0.05, z: 0, duration: 0.3),
            SCNAction.rotateBy(x: 0, y: -0.05, z: 0, duration: 0.3)
        ])
        let continuousRotation = SCNAction.repeatForever(subtleRotation)
        tarsNode.runAction(continuousRotation, forKey: "speaking")
    }
    
    // Return TARS to idle state
    func animateTARSIdle() {
        guard let tarsNode = tarsNode, animationState != .idle else { return }
        
        animationState = .idle
        
        // Stop speaking animations
        tarsNode.removeAction(forKey: "speaking")
        
        // Find the light element
        let lightNodes = findNodes(named: "TARSMainBody", in: tarsNode)
            .flatMap { $0.childNodes.filter { $0.geometry is SCNBox && $0.position.z > 0 } }
        
        // Return to normal pulsing
        for lightNode in lightNodes {
            lightNode.removeAllActions()
            
            let normalPulse = SCNAction.sequence([
                SCNAction.scale(to: 1.1, duration: 1.0),
                SCNAction.scale(to: 1.0, duration: 1.0)
            ])
            let continuousNormalPulse = SCNAction.repeatForever(normalPulse)
            lightNode.runAction(continuousNormalPulse)
            
            // Return to blue color
            if let material = lightNode.geometry?.firstMaterial {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = UIColor.blue
                material.diffuse.contents = UIColor.blue.withAlphaComponent(0.7)
                SCNTransaction.commit()
            }
        }
        
        // Smoothly rotate back to original orientation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        tarsNode.eulerAngles = SCNVector3Zero
        SCNTransaction.commit()
    }
    
    // Make TARS move to a new position
    func moveTARS(to position: SCNVector3) {
        guard let tarsNode = tarsNode else { return }
        
        animationState = .moving
        
        // Calculate movement vector
        let movementVector = SCNVector3(
            position.x - tarsNode.position.x,
            position.y - tarsNode.position.y,
            position.z - tarsNode.position.z
        )
        
        // First turn to face the direction
        let angle = atan2(movementVector.x, movementVector.z)
        
        // Rotate to face direction
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        tarsNode.eulerAngles.y = angle
        SCNTransaction.commit()
        
        // Then move
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        SCNTransaction.completionBlock = { [weak self] in
            self?.animationState = .idle
        }
        
        // Move to new position
        tarsNode.position = position
        
        SCNTransaction.commit()
    }
    
    // Helper to find nodes by name
    private func findNodes(named name: String, in rootNode: SCNNode) -> [SCNNode] {
        var results: [SCNNode] = []
        
        if rootNode.name == name {
            results.append(rootNode)
        }
        
        for childNode in rootNode.childNodes {
            results.append(contentsOf: findNodes(named: name, in: childNode))
        }
        
        return results
    }
    
    // MARK: - ARSCNViewDelegate Methods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Handle adding of anchors, particularly plane anchors
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = createPlaneNode(for: planeAnchor)
        node.addChildNode(planeNode)
        
        detectedPlanes[planeAnchor] = planeNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update plane visualizations when planes are updated
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let planeNode = detectedPlanes[planeAnchor] else { return }
        
        updatePlaneNode(planeNode, for: planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // Remove plane visualizations when planes are removed
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        detectedPlanes.removeValue(forKey: planeAnchor)
    }
    
    // Create a visualization for a detected plane
    private func createPlaneNode(for anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        // Semi-transparent blue material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue.withAlphaComponent(0.3)
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 0.3
        
        // Position plane correctly
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        // Rotate plane to match orientation
        planeNode.eulerAngles.x = -.pi / 2
        
        return planeNode
    }
    
    // Update a plane visualization
    private func updatePlaneNode(_ node: SCNNode, for anchor: ARPlaneAnchor) {
        guard let planeNode = node.childNodes.first,
              let plane = planeNode.geometry as? SCNPlane else { return }
        
        // Update plane size
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        
        // Update position
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
    
    // Handle tap for placing TARS
    func handleTap(at point: CGPoint) -> Bool {
        guard let arView = arView, !tarsPlaced else { return false }
        
        // Perform hit test to find where user tapped
        let hitTestResults = arView.hitTest(point, types: .existingPlaneUsingExtent)
        
        if let hitResult = hitTestResults.first {
            // Convert hit test result to 3D position
            let position = SCNVector3(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y,
                hitResult.worldTransform.columns.3.z
            )
            
            // Place TARS at this position
            return placeTARS(at: position)
        }
        
        return false
    }
}
