//
//  ViewController.swift
//  CrazyShark
//
//  Created by Juan Garrido Peyres on 10/06/2019.
//  Copyright © 2019 Juan Garrido Peyres. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate, SharkGameProtocol {

    
    
    @IBOutlet var sceneView: ARSKView!
    var spriteCounter = 0
    var sharkCounter = 0
    var firstFishCounter = 0
    var secondFishCounter = 0
    var thirdFishCounter = 0
    @IBOutlet var sharkScoreText: UILabel!
    @IBOutlet var playerScoreText: UILabel!
    var sharkScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
            if let sharkGameScene = scene as? Scene {
                sharkGameScene.sharkGame = self
            }
//            let sharkGameScene = Scene()
//            sharkGameScene.sharkGame = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let fishType = anchor.name
        switch fishType {
        case "shark":
            let sprite = SKSpriteNode(imageNamed: "sharkFirst")
            sprite.name = "shark"
            return sprite
        case "firstFish":
            let sprite = SKSpriteNode(imageNamed: "firstFish")
            sprite.name = "firstFish"
            return sprite
        case "secondFish":
            let sprite = SKSpriteNode(imageNamed: "secondFish")
            sprite.name = "secondFish"
            return sprite
        case "thirdFish":
            let sprite = SKSpriteNode(imageNamed: "thirdFish")
            sprite.name = "thirdFish"
            return sprite
        default:
            let sprite = SKSpriteNode(imageNamed: "firstFish")
            sprite.name = "firstFish"
            return sprite
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func sharkScoreDidChange(score: Int) {
        self.sharkScoreText.text = "\(score)"
    }
    
    func playerScoreDidChange(score: Int) {
        self.playerScoreText.text = "\(score)"
    }
    
}
