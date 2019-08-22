//
//  ViewController.swift
//  Chapter02
//
//  Created by midland on 2019/8/22.
//  Copyright © 2019 JQHxx. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Properties
    var trackingStatus: String = ""
    var focusNode: SCNNode!
    var diceNodes: [SCNNode] = []
    var diceCount: Int = 1
    var diceStyle: Int = 0
    let diceOffset: [SCNVector3] = [SCNVector3(0.0,0.0,0.0),
                                    SCNVector3(-0.05, 0.00, 0.0),
                                    SCNVector3(0.05, 0.00, 0.0),
                                    SCNVector3(-0.05, 0.05, 0.02),
                                    SCNVector3(0.05, 0.05, 0.02)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSceneView()
        initScene()
        initARSession()
        loadModels()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
     // MARK: - Actions
    @IBAction func styleButtonAction(_ sender: UIButton) {
        diceStyle = diceStyle >= 4 ? 0 : diceStyle + 1
    }
    
    @IBAction func resetButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func startButtonAction(_ sender: UIButton) {
    }
    
    //
    @IBAction func swiperGesAction(_ sender: UISwipeGestureRecognizer) {
        // 1
        guard let frame = self.sceneView.session.currentFrame else { return }
        // 2
        for count in 0..<diceCount {
            throwDiceNode(transform: SCNMatrix4(frame.camera.transform),
                          offset: diceOffset[count])
        }
    }
    
    
    
    // MARK: - Private methods
    // 场景显示视图
    private func initSceneView() {
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // 调试选项
        sceneView.debugOptions = [
            //ARSCNDebugOptions.showFeaturePoints,
            //ARSCNDebugOptions.showWorldOrigin,
            //SCNDebugOptions.showBoundingBoxes,
            //SCNDebugOptions.showWireframe
        ]
    }
    
    // 场景
    private func initScene() {
        // Create a new scene
        // art.scnassets/ship.scn
        let scene = SCNScene()
        scene.isPaused = false
            // SCNScene(named: "ARResource.scnassets/SimpleScene.scn")!
        // Set the scene to the view
        sceneView.scene = scene
        
        scene.lightingEnvironment.contents = "ARResource.scnassets/Textures/Environment_cube.jpg"
        scene.lightingEnvironment.intensity = 2
    }
    
    // ARSession
    private func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        // 用于指定虚拟内容与真实世界的关系
        config.worldAlignment = .gravity
        // 此属性允许 AR 会话捕获音频
        config.providesAudioData = false
        sceneView.session.run(config)
    }
    
    //
    private func loadModels() {
        // 1
        guard let diceScene = SCNScene(
            named: "ARResource.scnassets/DiceScene.scn") else {
                return
        }
        // 2
        for count in 0..<5 {
            // 3
            diceNodes.append(diceScene.rootNode.childNode(
                withName: "Dice\(count)",
                recursively: false)!)
        }
        
        guard let focusScene = SCNScene(
            named: "ARResource.scnassets/Models/FocusScene.scn") else {
                return
        }
        focusNode = focusScene.rootNode.childNode(
            withName: "focus", recursively: false)!
        
        sceneView.scene.rootNode.addChildNode(focusNode)
    }
    
}

// MARK: - Helper Functions
extension ViewController {
    
    func throwDiceNode(transform: SCNMatrix4, offset: SCNVector3) {
        // 1
        let position = SCNVector3(transform.m41 + offset.x,
                                  transform.m42 + offset.y,
                                  transform.m43 + offset.z)
        // 2 (新一个场景，重新设置配置)
        let diceNode = diceNodes[diceStyle].clone()
        diceNode.name = "dice"
        diceNode.position = position
        //3
        sceneView.scene.rootNode.addChildNode(diceNode)
        //diceCount -= 1
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    // MARK: - SceneKit Management
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // self.statusLabel.text = self.trackingStatus
        }
    }
    
    // MARK: - Session State Management
    func session(_ session: ARSession,
                 cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        // 1
        case .notAvailable:
            self.trackingStatus = "Tacking:  Not available!"
            break
        // 2
        case .normal:
            self.trackingStatus = "Tracking: All Good!"
            break
        // 3
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                self.trackingStatus = "Tracking: Limited due to excessive motion!"
                break
            // 3.1
            case .insufficientFeatures:
                self.trackingStatus = "Tracking: Limited due to insufficient features!"
                break
            // 3.2
            case .initializing:
                self.trackingStatus = "Tracking: Initializing..."
                break
            case .relocalizing:
                self.trackingStatus = "Tracking: Relocalizing..."
            default:
                break
            }
        }
    }
    

    // MARK: - Session Error Managent
    func session(_ session: ARSession, didFailWithError error: Error) {
         self.trackingStatus = "AR Session Failure: \(error)"
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        self.trackingStatus = "AR Session Was Interrupted!"
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        self.trackingStatus = "AR Session Interruption Ended"
        
    }
}
